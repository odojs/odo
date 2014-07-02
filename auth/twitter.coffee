define [
	'passport'
	'passport-twitter'
	'odo/config'
	'odo/hub'
	'node-uuid'
	'redis'
	'odo/express'
], (passport, passporttwitter, config, hub, uuid, redis, express) ->
	class TwitterAuthentication
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
			
		web: =>
			passport.use new passporttwitter.Strategy(
				consumerKey: config.passport.twitter['consumer key']
				consumerSecret: config.passport.twitter['consumer secret']
				callbackURL: config.passport.twitter['host'] + '/odo/auth/twitter/callback'
				passReqToCallback: true
			, @signin)
			
			express.get '/odo/auth/twitter', passport.authenticate 'twitter'
			express.get '/odo/auth/twitter/callback', (req, res, next) ->
				passport.authenticate('twitter', (err, user, info) ->
					return next err if err?
					
					if !user
						if config.odo.auth?.twitter?.failureRedirect?
							return res.redirect config.odo.auth.twitter.failureRedirect
						return res.redirect '/#auth/twitter/failure'
						
					req.logIn user, (err) ->
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if config.odo.auth?.twitter?.successRedirect?
							return res.redirect config.odo.auth.twitter.successRedirect
						return res.redirect '/#auth/twitter/success'
				)(req, res, next)
				
			express.post '/odo/auth/twitter/disconnect', (req, res) =>
				if !req.body.id?
					res.send 400, 'Id required'
					return
					
				if !req.body.profile?
					res.send 400, 'Profile required'
					return
					
				console.log "Disconnecting twitter from #{req.body.id}"
				hub.send
					command: 'disconnectTwitterFromUser'
					payload:
						id: req.body.id
						profile: req.body.profile
		
		projection: =>
			hub.receive 'userTwitterConnected', (event, cb) =>
				@db().hset "#{config.odo.domain}:usertwitter", event.payload.profile.id, event.payload.id, ->
					cb()
					
			hub.receive 'userTwitterDisconnected', (event, cb) =>
				@db().hdel "#{config.odo.domain}:usertwitter", event.payload.profile.id, ->
					cb()
		
		signin: (req, token, tokenSecret, profile, done) =>
			userid = null
			
			@get profile.id, (err, userid) =>
				if err?
					done err
					return
				
				if req.user? and userid? and req.user.id isnt userid
					done null, false, { message: 'This Twitter account is connected to another account' }
					return
				
				if req.user?
					console.log 'user already exists, connecting twitter to user'
					userid = req.user.id
					hub.send
						command: 'connectTwitterToUser'
						payload:
							id: userid
							profile: profile
				
				else if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v4()
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'connectTwitterToUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'assignDisplayNameToUser'
						payload:
							id: userid
							displayName: profile.displayName
				
				else
					hub.send
						command: 'connectTwitterToUser'
						payload:
							id: userid
							profile: profile
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		
		get: (id, callback) ->
			@db().hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				@db().hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data

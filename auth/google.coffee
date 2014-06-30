define [
	'passport'
	'passport-google'
	'odo/config'
	'odo/hub'
	'node-uuid'
	'redis'
	'odo/express'
], (passport, passportgoogle, config, hub, uuid, redis, express) ->
	db = redis.createClient config.redis.port, config.redis.host
	
	class GoogleAuthentication
		web: =>
			passport.use new passportgoogle.Strategy(
				realm: config.passport.google['realm']
				returnURL: config.passport.google['host'] + '/odo/auth/google/callback'
				passReqToCallback: true
			, @signin)
			
			express.get '/odo/auth/google', passport.authenticate 'google'
			express.get '/odo/auth/google/callback', (req, res, next) ->
				passport.authenticate('google', (err, user, info) ->
					return next err if err?
					
					if !user
						if config.odo.auth?.google?.failureRedirect?
							return res.redirect config.odo.auth.google.failureRedirect
						return res.redirect '/#auth/google/failure'
						
					req.logIn user, (err) ->
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if config.odo.auth?.google?.successRedirect?
							return res.redirect config.odo.auth.google.successRedirect
						return res.redirect '/#auth/google/success'
				)(req, res, next)
				
			express.post '/odo/auth/google/disconnect', (req, res) =>
				if !req.body.id?
					res.send 400, 'Id required'
					return
					
				if !req.body.profile?
					res.send 400, 'Profile required'
					return
					
				console.log "Disconnecting google from #{req.body.id}"
				hub.send
					command: 'disconnectGoogleFromUser'
					payload:
						id: req.body.id
						profile: req.body.profile
		
		projection: =>
			hub.receive 'userGoogleConnected', (event, cb) =>
				db.hset "#{config.odo.domain}:usergoogle", event.payload.profile.id, event.payload.id, ->
					cb()
					
			hub.receive 'userGoogleDisconnected', (event, cb) =>
				db.hdel "#{config.odo.domain}:usergoogle", event.payload.profile.id, ->
					cb()
		
		signin: (req, identifier, profile, done) =>
			userid = null
			
			profile.id = identifier
			
			@get profile.id, (err, userid) =>
				if err?
					done err
					return
				
				if req.user? and userid? and req.user.id isnt userid
					done null, false, { message: 'This Google account is connected to another account' }
					return
				
				if req.user?
					console.log 'user already exists, connecting google to user'
					userid = req.user.id
					hub.send
						command: 'connectGoogleToUser'
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
						command: 'connectGoogleToUser'
						payload:
							id: userid
							profile: profile
				
				else
					hub.send
						command: 'connectGoogleToUser'
						payload:
							id: userid
							profile: profile
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:usergoogle", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				db.hget "#{config.odo.domain}:usergoogle", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data

define [
	'passport'
	'passport-facebook'
	'odo/config'
	'odo/messaging/hub'
	'node-uuid'
	'redis'
	'odo/express'
], (passport, passportfacebook, config, hub, uuid, redis, express) ->
	db = redis.createClient config.redis.port, config.redis.host
	
	class FacebookAuthentication
		web: =>
			passport.use new passportfacebook.Strategy(
				clientID: config.passport.facebook['app id']
				clientSecret: config.passport.facebook['app secret']
				callbackURL: config.passport.facebook['host'] + '/odo/auth/facebook/callback'
				passReqToCallback: true
			, @signin)

			express.get '/odo/auth/facebook', passport.authenticate 'facebook'
			express.get '/odo/auth/facebook/callback', (req, res, next) ->
				passport.authenticate('facebook', (err, user, info) ->
					return next err if err?
					
					if !user
						if config.odo.auth?.facebook?.failureRedirect?
							return res.redirect config.odo.auth.facebook.failureRedirect
						return res.redirect '/#auth/facebook/failure'
						
					req.logIn user, (err) ->
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if config.odo.auth?.facebook?.successRedirect?
							return res.redirect config.odo.auth.facebook.successRedirect
						return res.redirect '/#auth/facebook/success'
				)(req, res, next)
		
		projection: =>
			hub.receive 'userFacebookConnected', (event, cb) =>
				db.hset "#{config.odo.domain}:userfacebook", event.payload.profile.id, event.payload.id, ->
					cb()
			
			hub.receive 'userFacebookDisconnected', (event, cb) =>
				db.hdel "#{config.odo.domain}:userfacebook", event.payload.profile.id, ->
					cb()
				
		signin: (req, accessToken, refreshToken, profile, done) =>
			userid = null
			
			@get profile.id, (err, userid) =>
				if err?
					done err
					return
				
				if req.user? and userid? and req.user.id isnt userid
					done null, false, { message: 'This Facebook account is connected to another account' }
					return
					
				if req.user?
					console.log 'user already exists, connecting facebook to user'
					userid = req.user.id
					hub.send
						command: 'connectFacebookToUser'
						payload:
							id: userid
							profile: profile
				
				else if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v1()
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'connectFacebookToUser'
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
						command: 'connectFacebookToUser'
						payload:
							id: userid
							profile: profile
				
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:userfacebook", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				db.hget "#{config.odo.domain}:userfacebook", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data

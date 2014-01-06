define ['passport', 'passport-google', 'odo/config', 'odo/hub', 'node-uuid', 'redis'], (passport, passportgoogle, config, hub, uuid, redis) ->
	db = redis.createClient()
	
	class GoogleAuthentication
		constructor: ->
			@receive =
				userGoogleAttached: (event) =>
					db.hset "#{config.odo.domain}:usergoogle", event.payload.profile.id, event.payload.id
		
		configure: (app) =>
			passport.use new passportgoogle.Strategy(
				realm: config.passport.google['realm']
				returnURL: config.passport.google['host'] + '/auth/google/callback'
				passReqToCallback: true
			, (req, identifier, profile, done) =>
				userid = null
				
				profile.id = identifier
				
				if req.user?
					console.log 'user already exists, using it\'s id'
					userid = req.user.id
				
				@get profile.id, (err, userid) =>
					if err?
						done err
						return
					
					if !userid?
						console.log 'no user exists yet, creating a new id'
						userid = uuid.v1()
						hub.send
							command: 'startTrackingUser'
							payload:
								id: userid
								profile: profile
						
						console.log 'attaching google to user'
						hub.send
							command: 'attachGoogleToUser'
							payload:
								id: userid
								profile: profile
					
					user = {
						id: userid
						profile: profile
					}
					
					done null, user
			)
			
		init: (app) =>
			app.get '/auth/google', passport.authenticate 'google'
			app.get '/auth/google/callback', passport.authenticate('google', {
				successRedirect: '/'
				failureRedirect: '/'
			})
		
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
define [
	'passport'
	'passport-google'
	'odo/config'
	'odo/messaging/hub'
	'node-uuid'
	'redis'
	'odo/express/app'
], (passport, passportgoogle, config, hub, uuid, redis, app) ->
	db = redis.createClient()
	
	class GoogleAuthentication
		web: =>
			passport.use new passportgoogle.Strategy(
				realm: config.passport.google['realm']
				returnURL: config.passport.google['host'] + '/odo/auth/google/callback'
				passReqToCallback: true
			, @signin)
			
			app.get '/odo/auth/google', passport.authenticate 'google'
			app.get '/odo/auth/google/callback', passport.authenticate('google', {
				successRedirect: '/#auth/google/success'
				failureRedirect: '/#auth/google/failure'
			})
		
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
					done null, false, { message: 'This Google account is connected to another Blackbeard account' }
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
					userid = uuid.v1()
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
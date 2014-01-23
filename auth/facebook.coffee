define ['passport', 'passport-facebook', 'odo/infra/config', 'odo/infra/hub', 'node-uuid', 'redis'], (passport, passportfacebook, config, hub, uuid, redis) ->
	db = redis.createClient()
	
	class FacebookAuthentication
		receive: (hub) =>
			hub.receive 'userFacebookConnected', (event, cb) =>
				db.hset "#{config.odo.domain}:userfacebook", event.payload.profile.id, event.payload.id, ->
					cb()
			
			hub.receive 'userFacebookDisconnected', (event, cb) =>
				db.hdel "#{config.odo.domain}:userfacebook", event.payload.profile.id, ->
					cb()
					
		
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
					
		
		configure: (app) =>
			passport.use new passportfacebook.Strategy(
				clientID: config.passport.facebook['app id']
				clientSecret: config.passport.facebook['app secret']
				callbackURL: config.passport.facebook['host'] + '/odo/auth/facebook/callback'
				passReqToCallback: true
			, (req, accessToken, refreshToken, profile, done) =>
				userid = null
				
				@get profile.id, (err, userid) =>
					if err?
						done err
						return
					
					if req.user? and userid? and req.user.id isnt userid
						done null, false, { message: 'This Facebook account is connected to another Blackbeard account' }
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
			)
			
		init: (app) =>
			app.get '/odo/auth/facebook', passport.authenticate 'facebook'
			app.get '/odo/auth/facebook/callback', passport.authenticate('facebook', {
				successRedirect: '/#auth/facebook/success'
				failureRedirect: '/#auth/facebook/failure'
			})
			app.get '/odo/auth/facebook'
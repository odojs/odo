define ['passport', 'passport-facebook', 'odo/config', 'odo/hub', 'node-uuid', 'redis'], (passport, passportfacebook, config, hub, uuid, redis) ->
	db = redis.createClient()
	
	class FacebookAuthentication
		constructor: ->
			@receive =
				userFacebookAttached: (event) =>
					console.log 'FacebookAuthentication userFacebookAttached'
					
					db.hset "#{config.odo.domain}:userfacebook", event.payload.profile.id, event.payload.id
		
		configure: (app) =>
			console.log config.passport.facebook['host'] + '/auth/facebook/callback'
			passport.use new passportfacebook.Strategy(
				clientID: config.passport.facebook['app id']
				clientSecret: config.passport.facebook['app secret']
				callbackURL: config.passport.facebook['host'] + '/auth/facebook/callback'
				passReqToCallback: true
			, (req, accessToken, refreshToken, profile, done) =>
				userid = null
				
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
						
						console.log 'attaching facebook to user'
						hub.send
							command: 'attachFacebookToUser'
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
			app.get '/auth/facebook', passport.authenticate 'facebook'
			app.get '/auth/facebook/callback', passport.authenticate('facebook', {
				successRedirect: '/'
				failureRedirect: '/'
			})
		
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
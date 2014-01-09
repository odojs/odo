define ['passport', 'passport-twitter', 'odo/config', 'odo/hub', 'node-uuid', 'redis'], (passport, passporttwitter, config, hub, uuid, redis) ->
	db = redis.createClient()
	
	class TwitterAuthentication
		constructor: ->
			@receive =
				userTwitterAttached: (event) =>
					console.log 'TwitterAuthentication userTwitterAttached'
					
					db.hset "#{config.odo.domain}:usertwitter", event.payload.profile.id, event.payload.id
		
		configure: (app) =>
			passport.use new passporttwitter.Strategy(
				consumerKey: config.passport.twitter['consumer key']
				consumerSecret: config.passport.twitter['consumer secret']
				callbackURL: config.passport.twitter['host'] + '/odo/auth/twitter/callback'
				passReqToCallback: true
			, (req, token, tokenSecret, profile, done) =>
				userid = null
				
				@get profile.id, (err, userid) =>
					if err?
						done err
						return
					
					if req.user?
						console.log 'user already exists, attaching twitter to user'
						userid = req.user.id
						hub.send
							command: 'attachTwitterToUser'
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
						
						console.log 'attaching twitter to user'
						hub.send
							command: 'attachTwitterToUser'
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
			app.get '/odo/auth/twitter', passport.authenticate 'twitter'
			app.get '/odo/auth/twitter/callback', passport.authenticate('twitter', {
				successRedirect: '/'
				failureRedirect: '/'
			})
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				db.hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data
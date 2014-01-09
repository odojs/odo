define ['passport', 'passport-local', 'odo/config', 'odo/hub', 'node-uuid', 'redis', 'odo/projections/userprofile'], (passport, passportlocal, config, hub, uuid, redis, UserProfile) ->
	db = redis.createClient()
	
	class LocalAuthentication
		constructor: ->
			@receive =
				userHasLocalSignin: (event) =>
					console.log 'LocalAuthentication userHasLocalSignin'
					
					db.hset "#{config.odo.domain}:localusers", event.payload.profile.username, event.payload.id
		
		configure: (app) =>
			passport.use new passportlocal.Strategy (username, password, done) =>
				userid = null
				
				@get username, (err, userid) =>
					if err?
						done err
						return
					
					if !userid?
						console.log 'User not found'
						done null, false, { message: 'Incorrect username or password.' }
						return
					
					new UserProfile().get userid, (err, user) =>
						if err?
							done err
							return
					
						if user.local.profile.password isnt password
							console.log 'Password not correct'
							done null, false, { message: 'Incorrect username or password.' }
							return
						
						console.log 'Returning successfully'
						done null, user
			
		init: (app) =>
			app.post '/odo/auth/local', passport.authenticate('local', {
				successRedirect: '/'
				failureRedirect: '/'
			})
			
			app.post '/odo/auth/local/signup', (req, res) =>
				if !req.body.displayName?
					res.send 400, 'Full name required'
				if !req.body.username?
					res.send 400, 'Email address required'
				if !req.body.password?
					res.send 400, 'Password required'
				if req.body.password isnt req.body.passwordconfirm
					res.send 400, 'Passwords must match'
				
				userid = null
				
				profile =
					displayName: req.body.displayName
					username: req.body.username
					password: req.body.password
				
				if req.user?
					console.log 'user already exists, creating local signin'
					userid = req.user.id
					profile.id = req.user.id
				
				else
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v1()
					profile.id = userid
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
				console.log 'creating a local signin for user'
				hub.send
					command: 'createLocalSigninForUser'
					payload:
						id: userid
						profile: profile
				
				new UserProfile().get userid, (err, user) =>
					if err?
						res.send 500, 'Couldn\'t find user'
						return
						
					req.login user, (err) =>
						if err?
							res.send 500, 'Couldn\'t login user'
							return
						
						res.redirect '/'
				
		
		get: (username, callback) ->
			console.log 
			
			db.hget "#{config.odo.domain}:localusers", username, (err, data) =>
				if err?
					callback err
					return
					
				callback null, data
define ['passport', 'passport-local', 'odo/config', 'odo/hub', 'node-uuid', 'redis', 'odo/projections/userprofile'], (passport, passportlocal, config, hub, uuid, redis, UserProfile) ->
	db = redis.createClient()
	
	class LocalAuthentication
		constructor: ->
			@receive =
				userHasLocalSignin: (event) =>
					console.log 'LocalAuthentication userHasLocalSignin'
					
					db.hset "#{config.odo.domain}:localusers", event.payload.profile.username, event.payload.id
				
				# if they have a local sign in we should update the sign in check
				userHasUsername: (event) =>
					console.log 'LocalAuthentication userHasUsername'
					
					@get event.payload.username, (err, userid) =>
						if err?
							console.log err
							return
						
						if !userid?
							return
					
						db.hset "#{config.odo.domain}:localusers", event.payload.username, event.payload.id
				
		
		get: (username, callback) ->
			console.log 
			
			db.hget "#{config.odo.domain}:localusers", username, (err, data) =>
				if err?
					callback err
					return
					
				callback null, data
				
		
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
			
			app.get '/odo/auth/local/test', (req, res) =>
				if !req.query.username?
					res.send
						isValid: no
						message: 'Username required'
					return
				
				if !req.query.password?
					res.send
						isValid: no
						message: 'Password required'
					return
				
				@get req.query.username, (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
					
					if !userid?
						res.send
							isValid: no
							message: 'Incorrect username or password'
						return
					
					new UserProfile().get userid, (err, user) =>
						if err?
							console.log err
							res.send 500, 'Woops'
							return
						
						if user.local.profile.password isnt req.query.password
							res.send
								isValid: no
								message: 'Incorrect username or password'
							return
						
						res.send
							isValid: yes
							message: 'Correct username and password'
						return
			
			app.get '/odo/auth/local/usernameavailability', (req, res) =>
				if !req.query.username?
					res.send
						isAvailable: no
						message: 'Required'
					return
				
				@get req.query.username, (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
					
					if !userid?
						res.send
							isAvailable: yes
							message: 'Available'
						return
					
					res.send
						isAvailable: no
						message: 'Taken'
					return
			
			app.post '/odo/auth/local/signup', (req, res) =>
				if !req.body.displayName?
					res.send 400, 'Full name required'
					return
					
				if !req.body.username?
					res.send 400, 'Username required'
					return
					
				if !req.body.password?
					res.send 400, 'Password required'
					return
					
				if req.body.password.length < 8
					res.send 400, 'Password needs to be at least eight letters long'
					return
					
				if req.body.password isnt req.body.passwordconfirm
					res.send 400, 'Passwords must match'
					return
				
				userid = null
				
				# this is so applications can add their own parameters to the local profile
				profile = req.body
				
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
				
				console.log 'assigning a username for user'
				hub.send
					command: 'assignUsernameToUser'
					payload:
						id: userid
						username: profile.username
				
				console.log 'assigning a displayName for user'
				hub.send
					command: 'assignDisplayNameToUser'
					payload:
						id: userid
						displayName: profile.displayName
				
				new UserProfile().get userid, (err, user) =>
					if err?
						res.send 500, 'Couldn\'t find user'
						return
						
					req.login user, (err) =>
						if err?
							res.send 500, 'Couldn\'t login user'
							return
						
						res.redirect '/'
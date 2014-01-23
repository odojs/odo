define ['passport', 'passport-local', 'odo/infra/config', 'odo/infra/hub', 'node-uuid', 'redis', 'odo/projections/userprofile'], (passport, passportlocal, config, hub, uuid, redis, UserProfile) ->
	db = redis.createClient()
	
	class LocalAuthentication
		receive: (hub) =>
			hub.receive 'userHasLocalSignin', (event, cb) =>
				db.hset "#{config.odo.domain}:localusers", event.payload.profile.username, event.payload.id, ->
					cb()
			
			# if they have a local sign in we should update the sign in check
			hub.receive 'userHasUsername', (event, cb) =>
				@get event.payload.username, (err, userid) =>
					if err?
						console.log err
						cb()
						return
					
					if !userid?
						cb()
						return
				
					db.hset "#{config.odo.domain}:localusers", event.payload.username, event.payload.id, ->
						cb()
			
			hub.receive 'userLocalSigninRemoved', (event, cb) =>
				db.hdel "#{config.odo.domain}:localusers", event.payload.profile.username, ->
					cb()
			
			hub.receive 'userHasPasswordResetToken', (event, cb) =>
				key = "#{config.odo.domain}:passwordresettoken:#{event.payload.token}"
				console.log key
				db
					.multi()
					.set(key, event.payload.id)
					.expire(key, 60 * 60 * 24)
					.exec (err, replies) =>
						if err?
							console.log err
							cb()
							return
						
						cb()
		
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
						done null, false, { message: 'Incorrect username or password.' }
						return
					
					new UserProfile().get userid, (err, user) =>
						if err?
							done err
							return
					
						if user.local.profile.password isnt password
							done null, false, { message: 'Incorrect username or password.' }
							return
						
						done null, user
			
		init: (app) =>
			app.post '/odo/auth/local', passport.authenticate('local', {
				successRedirect: '/#auth/local/success'
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
			
			app.get '/odo/auth/local/resettoken', (req, res) =>
				if !req.query.token?
					res.send 400, 'Token required'
					return
				
				db.get "#{config.odo.domain}:passwordresettoken:#{req.query.token}", (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
					
					if !userid?
						res.send
							isValid: no
							message: 'Token not valid'
						return
					
					new UserProfile().get userid, (err, user) =>
						if err?
							console.log err
							res.send 500, 'Woops'
							return
						
						if !userid?
							res.send
								isValid: no
								message: 'Token not valid'
							return
						
						res.send
							isValid: yes
							username: user.username
							message: 'Token valid'
			
			app.post '/odo/auth/local/resettoken', (req, res) =>
				if !req.body.email?
					res.send 400, 'Email address required'
					return
				
				db.hget "#{config.odo.domain}:useremail", req.body.email, (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
					
					if !userid?
						res.send 400, 'Incorrect email address'
						return
					
					token = uuid.v1()
					console.log "createPasswordResetToken #{token}"
					hub.send
						command: 'createPasswordResetToken'
						payload:
							id: userid
							token: uuid.v1()
						
					res.send 'Token generated'
			
			app.post '/odo/auth/local/reset', (req, res) =>
				if !req.body.token?
					res.send 400, 'Token required'
					return
					
				if !req.body.password?
					res.send 400, 'Password required'
					return
					
				if req.body.password.length < 8
					res.send 400, 'Password needs to be at least eight letters long'
					return
				
				key = "#{config.odo.domain}:passwordresettoken:#{req.body.token}"
				db.get key, (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
						
					if !userid?
						res.send 400, 'Token not valid'
						return
					
					console.log 'assigning a username for user'
					hub.send
						command: 'assignPasswordToUser'
						payload:
							id: userid
							password: req.body.password
					
					db.del key, (err, reply) =>
						if err?
							console.log err
							res.send 500, 'Woops'
							return
						
						res.send 'Done'
				
			
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
				
				console.log 'assigning a username for user'
				hub.send
					command: 'assignPasswordToUser'
					payload:
						id: userid
						password: profile.password
				
				new UserProfile().get userid, (err, user) =>
					if err?
						res.send 500, 'Couldn\'t find user'
						return
						
					req.login user, (err) =>
						if err?
							res.send 500, 'Couldn\'t login user'
							return
						
						res.redirect '/'
define [
	'passport'
	'passport-local'
	'node-uuid'
	'redis'
	'bcryptjs'
	'odo/config'
	'odo/hub'
	'odo/user'
	'odo/express'
], (passport, passportlocal, uuid, redis, bcrypt, config, hub, User, express) ->
	class LocalAuthentication
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
			
		web: =>
			passport.use new passportlocal.Strategy @signin
			
			express.post '/odo/auth/local', @auth
			express.get '/odo/auth/local/test', @test
			express.get '/odo/auth/local/usernameavailability', @usernameavailability
			express.get '/odo/auth/local/emailavailability', @emailavailability
			express.get '/odo/auth/local/resettoken', @getresettoken
			express.post '/odo/auth/local/reset', @reset
			express.post '/odo/auth/local/signup', @signup
			express.post '/odo/auth/local/assignusername', @assignusername
			express.post '/odo/auth/local/assignpassword', @assignpassword
			express.post '/odo/auth/local/remove', @remove
			
			express.post '/odo/auth/local/resettoken', (req, res) =>
				return res.send 400, 'Email address required' if !req.body.email?
				@generateresettoken req.body.email, (err, result) =>
					throw err if err?
					res.send result
		
		updateemail: (m, cb) =>
			@db().hset "#{config.odo.domain}:localemails", m.email, m.id, =>
				if m.oldemail?
					@db().hdel "#{config.odo.domain}:localemails", m.oldemail, -> cb()
				else
					cb()

		projection: =>
			hub.every 'create local signin for user {id}', (m, cb) =>
				@db().hset "#{config.odo.domain}:localusers", m.profile.username, m.id, -> cb()
				
			hub.every 'create local signin for user {id}', (m, cb) =>
				@db().hset "#{config.odo.domain}:localemails", m.profile.email, m.id, -> cb()
				
			hub.every 'create invitation {id}', @updateemail
			hub.every 'create verify email token for email {email} of user {id}', @updateemail
			hub.every 'assign email address {email} to user {id}', @updateemail

			# if they have a local sign in we should update the sign in check
			hub.every 'assign username {username} to user {id}', (m, cb) =>
				@get m.username, (err, userid) =>
					throw err if err?
					return cb() if !userid?
					@db().hset "#{config.odo.domain}:localusers", m.username, m.id, -> cb()
			
			hub.every 'remove local signin from user {id}', (m, cb) =>
				@db().hdel "#{config.odo.domain}:localusers", m.profile.username, -> cb()
			
			hub.every 'create password reset token for user {id}', (m, cb) =>
				key = "#{config.odo.domain}:passwordresettoken:#{m.token}"
				@db()
					.multi()
					.set(key, m.id)
					.expire(key, 60 * 60 * 24)
					.exec (err, replies) =>
						throw err if err?
						cb()
		
		auth: (req, res, next) =>
			passport.authenticate('local', (err, user, info) ->
				return next err if err?
				
				if !user
					if config.odo.auth?.local?.failureRedirect?
						return res.redirect config.odo.auth.local.failureRedirect
					return res.redirect '/#auth/local/failure'
					
				req.logIn user, (err) ->
					return next err if err?
					
					if req.session?.returnTo?
						returnTo = req.session.returnTo
						delete req.session.returnTo
						return res.redirect returnTo
					if config.odo.auth?.local?.successRedirect?
						return res.redirect config.odo.auth.local.successRedirect
					return res.redirect '/#auth/local/success'
			)(req, res, next)
		
		signin: (username, password, done) =>
			userid = null
			
			@get username, (err, userid) =>
				throw err if err?
				return done null, false, { message: 'Incorrect username or password.', userid: null } if !userid?
				
				new User().get userid, (err, user) =>
					throw err if err?
					if !bcrypt.compareSync password, user.local.profile.password
						return done null, false, { message: 'Incorrect username or password.', userid: userid }
					done null, user
		
		test: (req, res) =>
			return res.send isValid: no, message: 'Username required' if !req.query.username?
			return res.send isValid: no, message: 'Password required' if !req.query.password?
			
			@get req.query.username, (err, userid) =>
				throw err if err?
				return res.send isValid: no, message: 'Incorrect username or password' if !userid?
				
				password = req.query.password
				
				new User().get userid, (err, user) =>
					throw err if err?
					
					if !bcrypt.compareSync password, user.local.profile.password
						return res.send isValid: no, message: 'Incorrect username or password'
					
					res.send isValid: yes, message: 'Correct username and password'
		
		emailavailability: (req, res) =>	
			return res.send isAvailable: no, message: 'Required' if !req.query.email?
			
			@db().hget "#{config.odo.domain}:localemails", req.query.email, (err, userid) =>
				throw err if err?
				return res.send isAvailable: yes, message: 'Available'if !userid?
				res.send isAvailable: no, message: 'Taken'

		usernameavailability: (req, res) =>
			return res.send isAvailable: no, message: 'Required' if !req.query.username?
			
			@get req.query.username, (err, userid) =>
				throw err if err?
				return res.send isAvailable: yes, message: 'Available' if !userid?
				res.send isAvailable: no, message: 'Taken'
		
		getresettoken: (req, res) =>
			return res.send 400, 'Token required' if !req.query.token?
			
			@db().get "#{config.odo.domain}:passwordresettoken:#{req.query.token}", (err, userid) =>
				throw err if err?
				return res.send isValid: no, message: 'Token not valid' if !userid?
				
				new User().get userid, (err, user) =>
					throw err if err?
					return res.send isValid: no, message: 'Token not valid' if !userid?
					res.send isValid: yes, username: user.username, message: 'Token valid'
		
		generateresettoken: (email, cb) =>
			@db().hget "#{config.odo.domain}:useremail", email, (err, userid) =>
				return cb err, null if err?
				return cb 'Incorrect email address', null if !userid?
				
				result =
					id: userid
					token: uuid.v4()
				
				hub.emit 'create password reset token for user {id}', result, ->
					hub.emit 'send password reset token to user {id}', result, ->
						cb null, result
		
		reset: (req, res) =>
			return res.send 400, 'Token required' if !req.body.token?
			return res.send 400, 'Password required' if !req.body.password?
			if req.body.password.length < 8
				return res.send 400, 'Password needs to be at least eight letters long'
			key = "#{config.odo.domain}:passwordresettoken:#{req.body.token}"
			@db().get key, (err, userid) =>
				throw err if err?
				return res.send 400, 'Token not valid' if !userid?
				
				hub.emit 'set password of user {id}',
					id: userid
					password: bcrypt.hashSync req.body.password, 12
				
				@db().del key, (err, reply) =>
					throw err if err?
					res.send 'Done'
		
		signup: (req, res) =>
			return res.send 400, 'Full name required' if !req.body.displayName?
			return res.send 400, 'Username required' if !req.body.username?
			return res.send 400, 'Password required' if !req.body.password?
			if req.body.password.length < 8
				return res.send 400, 'Password needs to be at least eight letters long'
			if req.body.password isnt req.body.passwordconfirm
				return res.send 400, 'Passwords must match'
			
			userid = null
			
			# this is so applications can add their own parameters to the local profile
			profile = req.body
			profile.password = bcrypt.hashSync profile.password, 12
			delete req.body.passwordconfirm
			
			if req.user?
				console.log 'user already exists, creating local signin'
				userid = req.user.id
				profile.id = req.user.id
			
			else
				console.log 'no user exists yet, creating a new id'
				userid = uuid.v4()
				profile.id = userid
				hub.emit 'start tracking user {id}',
					id: userid
					profile: profile
					
			hub.emit 'create local signin for user {id}',
				id: userid
				profile: profile
			
			hub.emit 'assign username {username} to user {id}',
				id: userid
				username: profile.username
			
			hub.emit 'assign displayName {displayName} to user {id}',
				id: userid
				displayName: profile.displayName
			
			hub.emit 'set password of user {id}',
				id: userid
				password: profile.password
			
			new User().get userid, (err, user) =>
				return res.send 500, 'Couldn\'t find user' if err?
				
				req.login user, (err) =>
					return res.send 500, 'Couldn\'t login user' if err?
					res.redirect '/'
		
		assignusername: (req, res) =>
			return res.send 400, 'Username required' if !req.body.username?
			return res.send 400, 'Id required' if !req.body.id?
			
			hub.emit 'assign username {username} to user {id}',
				id: req.body.id
				username: req.body.username
		
		assignpassword: (req, res) =>
			return res.send 400, 'Password required' if !req.body.password?
			return res.send 400, 'Id required' if !req.body.id?
			
			hub.emit 'set password of user {id}',
				id: req.body.id
				password: bcrypt.hashSync req.body.password, 12
		
		remove: (req, res) =>
			return res.send 400, 'Id required' if !req.body.id?
			return res.send 400, 'Profile required' if !req.body.profile?
			
			hub.emit 'remove local signin from user {id}',
				id: req.body.id
				profile: req.body.profile
		
		get: (username, callback) ->
			@db().hget "#{config.odo.domain}:localusers", username, (err, data) =>
				return callback err if err?
				callback null, data

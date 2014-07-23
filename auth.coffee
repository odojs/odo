define [
	'module'
	'passport'
	'odo/config'
	'redis'
	'odo/user'
	'odo/hub'
	'node-uuid'
	'odo/express'
	'odo/restify'
], (module, passport, config, redis, User, hub, uuid, express, restify) ->
	class Auth
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
		
		web: =>
			express.use passport.initialize()
			express.use passport.session()
			
			passport.serializeUser (user, done) ->
				done null, user.id

			passport.deserializeUser (id, done) ->
				new User().get id, done
			
			express.get '/odo/auth/signout', @signout
			express.get '/odo/auth/user', @user
			express.get '/odo/auth/forgot', @forgot
			express.post '/odo/auth/verifyemail', @verifyemail
			express.get '/odo/auth/checkemailverificationtoken', @checkemailverificationtoken
			express.post '/odo/auth/emailverified', @emailverified
			
			express.post '/odo/auth/assigndisplayname', @assigndisplayname
		
		api: =>
			restify.use passport.initialize()
			restify.use passport.session()
			
			passport.serializeUser (user, done) ->
				done null, user.id

			passport.deserializeUser (id, done) ->
				new User().get id, done
		
		projection: =>
			hub.receive 'userHasEmailAddress', (event, cb) =>
				@db().hset "#{config.odo.domain}:useremail", event.payload.email, event.payload.id, ->
					cb()
			
			hub.receive 'userHasVerifyEmailAddressToken', (event, cb) =>
				key = "#{config.odo.domain}:emailverificationtoken:#{event.payload.email}:#{event.payload.token}"
				@db()
					.multi()
					.set(key, event.payload.id)
					.expire(key, 60 * 60 * 24)
					.exec (err, replies) =>
						if err?
							console.log err
							cb()
							return
						
						cb()
						
		signout: (req, res) ->
			req.logout()
			return res.redirect config.odo.auth.signout if config.odo.auth.signout?
			res.redirect '/'
		
		user: (req, res) ->
			res.send req.user
		
		forgot: (req, res) =>
			if !req.query.email?
				res.send 400, 'Email address required'
				return
			
			@db().hget "#{config.odo.domain}:useremail", req.query.email, (err, userid) =>
				if err?
					console.log err
					res.send 500, 'Woops'
					return
				
				if !userid?
					res.send
						account: no
						message: 'No account found for this email address'
					return
					
				new User().get userid, (err, user) =>
					if err?
						res.send 500, 'Couldn\'t find user'
						return
					
					res.send
						account: yes
						local: user.local?
						facebook: user.facebook?
						google: user.google?
						twitter: user.twitter?
						username: user.username?
						message: 'Account found'
		
		verifyemail: (req, res) =>
			if !req.user?
				res.send 403, 'authentication required'
				return
				
			if !req.body.email?
				res.send 400, 'Email address required'
				return
				
			token = uuid.v4()
			console.log "createVerifyEmailAddressToken #{token}"
			hub.send
				command: 'createVerifyEmailAddressToken'
				payload:
					id: req.user.id
					email: req.body.email
					token: token
			
			res.send 'Done'
			
		checkemailverificationtoken: (req, res) =>
			if !req.user?
				res.send 403, 'Authentication required'
				return
				
			if !req.query.email?
				res.send 400, 'Email address required'
				return
				
			if !req.query.token?
				res.send 400, 'Token required'
				return
			
			key = "#{config.odo.domain}:emailverificationtoken:#{req.query.email}:#{req.query.token}"
			
			@db().get key, (err, userid) =>
				if err?
					console.log err
					res.send 500, 'Woops'
					return
				
				if !userid?
					res.send
						isValid: no
						message: 'Token not valid'
					return
			
				if req.user.id isnt userid
					res.send 403, 'authentication required'
					return
				
				res.send
					isValid: yes
					message: 'Token valid'
		
		emailverified: (req, res) =>
			if !req.user?
				res.send 403, 'authentication required'
				return
				
			if !req.body.email?
				res.send 400, 'Email address required'
				return
				
			if !req.body.token?
				res.send 400, 'Token required'
				return
			
			key = "#{config.odo.domain}:emailverificationtoken:#{req.body.email}:#{req.body.token}"
			
			@db().get key, (err, userid) =>
				if err?
					console.log err
					res.send 500, 'Woops'
					return
				
				if !userid?
					res.send 400, 'Token not valid'
					return
			
				if req.user.id isnt userid
					res.send 403, 'authentication required'
					return
				
				hub.send
					command: 'assignEmailAddressToUser'
					payload:
						id: userid
						email: req.body.email
						oldemail: req.user.email
						token: req.body.token
				
				@db().del key, (err, reply) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
						
					res.send 'Done'
					
		assigndisplayname: (req, res) =>
			if !req.body.displayName?
				res.send 400, 'Display name required'
				return
				
			if !req.body.id?
				res.send 400, 'Id required'
				return
				
			console.log "Assigning display name #{req.body.displayName} to #{req.body.id}"
			hub.send
				command: 'assignDisplayNameToUser'
				payload:
					id: req.body.id
					displayName: req.body.displayName
			

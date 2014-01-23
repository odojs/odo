define ['module', 'passport', 'odo/infra/config', 'redis', 'odo/projections/userprofile', 'odo/infra/hub', 'node-uuid'], (module, passport, config, redis, UserProfile, hub, uuid) ->
	db = redis.createClient()
	
	class Auth
		receive: (hub) =>
			hub.receive 'userHasEmailAddress', (event, cb) =>
				db.hset "#{config.odo.domain}:useremail", event.payload.email, event.payload.id, ->
					cb()
			
			hub.receive 'userHasVerifyEmailAddressToken', (event, cb) =>
				key = "#{config.odo.domain}:emailverificationtoken:#{event.payload.email}:#{event.payload.token}"
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
						
		configure: (app) =>
			app.route '/odo', app.modulepath(module.uri) + '/public'
			
			app.use passport.initialize()
			app.use passport.session()
			
			passport.serializeUser (user, done) ->
				done null, user.id

			passport.deserializeUser (id, done) ->
				new UserProfile().get id, done
			
		init: (app) =>
			app.get '/odo/auth/signout', (req, res) ->
				req.logout()
				res.redirect '/'
			
			app.get '/odo/auth/user', (req, res) ->
				if !req.user?
					res.send 403, 'authentication required'
					return
				
				res.send req.user
					
			app.get '/odo/auth/forgot', (req, res) =>
				if !req.query.email?
					res.send 400, 'Email address required'
					return
				
				db.hget "#{config.odo.domain}:useremail", req.query.email, (err, userid) =>
					if err?
						console.log err
						res.send 500, 'Woops'
						return
					
					if !userid?
						res.send
							account: no
							message: 'No account found for this email address'
						return
						
					new UserProfile().get userid, (err, user) =>
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
			
			app.post '/odo/auth/verifyemail', (req, res) =>
				if !req.user?
					res.send 403, 'authentication required'
					return
					
				if !req.body.email?
					res.send 400, 'Email address required'
					return
					
				token = uuid.v1()
				console.log "createVerifyEmailAddressToken #{token}"
				hub.send
					command: 'createVerifyEmailAddressToken'
					payload:
						id: req.user.id
						email: req.body.email
						token: uuid.v1()
				
				res.send 'Done'
			
			app.get '/odo/auth/checkemailverificationtoken', (req, res) =>
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
				
				db.get key, (err, userid) =>
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
		
			app.post '/odo/auth/emailverified', (req, res) =>
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
				
				db.get key, (err, userid) =>
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
							token: req.body.token
					
					db.del key, (err, reply) =>
						if err?
							console.log err
							res.send 500, 'Woops'
							return
							
						res.send 'Done'
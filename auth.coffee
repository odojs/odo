define [
	'module'
	'passport'
	'odo/config'
	'redis'
	'odo/hub'
	'node-uuid'
	'odo/express'
	'odo/restify'
	'odo/inject'
], (module, passport, config, redis, hub, uuid, express, restify, inject) ->
	class Auth
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
		
		web: =>
			express.use passport.initialize()
			express.use passport.session()
			
			passport.serializeUser (user, done) -> done null, user.id
			passport.deserializeUser (id, done) -> inject.one('odo user by id') id, done
			
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
			
			passport.serializeUser (user, done) -> done null, user.id
			passport.deserializeUser (id, done) -> inject.one('odo user by id') id, done
		
		projection: =>
			hub.every 'assign email address {email} to user {id}', (m, cb) =>
				@db().hset "#{config.odo.domain}:useremail", m.email, m.id, -> cb()
			
			hub.every 'create verify email token for email {email} of user {id}', (m, cb) =>
				key = "#{config.odo.domain}:emailverificationtoken:#{m.email}:#{m.token}"
				@db()
					.multi()
					.set(key, m.id)
					.expire(key, 60 * 60 * 24)
					.exec (err, replies) =>
						throw err if err?
						cb()
						
		signout: (req, res) ->
			req.logout()
			return res.redirect config.odo.auth.signout if config.odo.auth.signout?
			res.redirect '/'
		
		user: (req, res) ->
			res.send req.user
		
		forgot: (req, res) =>
			return res.send 400, 'Email address required' if !req.query.email?
			
			@db().hget "#{config.odo.domain}:useremail", req.query.email, (err, userid) =>
				throw err if err?
				
				if !userid?
					res.send
						account: no
						message: 'No account found for this email address'
					return
					
				inject.one('odo user by id') userid, (err, user) =>
					return res.send 500, 'Couldn\'t find user' if err?
					
					res.send
						account: yes
						local: user.local?
						facebook: user.facebook?
						google: user.google?
						twitter: user.twitter?
						username: user.username?
						message: 'Account found'
		
		verifyemail: (req, res) =>
			return res.send 403, 'authentication required' if !req.user?
			return res.send 400, 'Email address required' if !req.body.email?
			
			token = uuid.v4()
			hub.emit 'create verify email token for email {email} of user {id}',
				id: req.user.id
				email: req.body.email
				token: token
			
			res.send 'Done'
			
		checkemailverificationtoken: (req, res) =>
			return res.send 403, 'Authentication required' if !req.user?
			return res.send 400, 'Email address required' if !req.query.email?
			return res.send 400, 'Token required' if !req.query.token?
				
			key = "#{config.odo.domain}:emailverificationtoken:#{req.query.email}:#{req.query.token}"
			
			@db().get key, (err, userid) =>
				throw err if err?
				
				return res.send isValid: no, message: 'Token not valid' if !userid?
				return res.send 403, 'authentication required' if req.user.id isnt userid
				
				res.send isValid: yes, message: 'Token valid'
		
		emailverified: (req, res) =>
			return res.send 403, 'authentication required' if !req.user?
			return res.send 400, 'Email address required' if !req.body.email?
			return res.send 400, 'Token required' if !req.body.token?
				
			key = "#{config.odo.domain}:emailverificationtoken:#{req.body.email}:#{req.body.token}"
			
			@db().get key, (err, userid) =>
				throw err if err?
				return res.send 400, 'Token not valid' if !userid?
				return res.send 403, 'authentication required' if req.user.id isnt userid
					
				hub.emit 'assign email address {email} to user {id}',
					id: userid
					email: req.body.email
					oldemail: req.user.email
					token: req.body.token
				
				@db().del key, (err, reply) =>
					throw err if err?
					res.send 'Done'
					
		assigndisplayname: (req, res) =>
			return res.send 400, 'Display name required' if !req.body.displayName?
			return res.send 400, 'Id required' if !req.body.id?
			
			hub.emit 'assign displayName {displayName} to user {id}',
				id: req.body.id
				displayName: req.body.displayName
			

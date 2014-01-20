define ['module', 'passport', 'odo/config', 'redis', 'odo/projections/userprofile'], (module, passport, config, redis, UserProfile) ->
	db = redis.createClient()
	
	class Auth
		constructor: ->
			@receive =
				userHasEmailAddress: (event, cb) =>
					db.hset "#{config.odo.domain}:useremail", event.payload.email, event.payload.id, ->
						cb()
			
		
		configure: (app) =>
			app.route '/odo', app.modulepath(module.uri) + '/auth-public'
			
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
		
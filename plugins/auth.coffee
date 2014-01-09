define ['module', 'passport', 'odo/projections/userprofile'], (module, passport, UserProfile) ->
	configure: (app) ->
		app.route '/odo', app.modulepath(module.uri) + '/auth-public'
		
		app.use passport.initialize()
		app.use passport.session()
		
		passport.serializeUser (user, done) ->
			done null, user.id

		passport.deserializeUser (id, done) ->
			new UserProfile().get id, done
		
	init: (app) ->
		app.get '/odo/auth/signout', (req, res) ->
			req.logout()
			res.redirect '/'
		
		app.get '/odo/auth/user', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			res.send req.user
		
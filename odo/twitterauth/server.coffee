define ['module', 'path', 'express', 'passport', 'passport-twitter', 'odo/config', 'redis'], (module, path, express, passport, passporttwitter, config, redis) ->
	configure: (app) ->
		app.use('/odo/auth', express.static(path.dirname(module.uri) + '/public'))
		
		app.use passport.initialize()
		app.use passport.session()
		
		passport.use new passporttwitter.Strategy(
			consumerKey: config.passport.twitter['consumer key']
			consumerSecret: config.passport.twitter['consumer secret']
			callbackURL: 'http://thomascoats.com/auth/twitter/callback'
		, (token, tokenSecret, profile, done) ->
			user = {
				id: profile.id
				provider: profile.provider
				displayName: profile.displayName
			}
			
			client = redis.createClient()
			client.set('user:' + profile.id, JSON.stringify(user), (err) ->
				if err?
					done err
				
				client.quit()
				done null, user
			)
		)
		
		passport.serializeUser (user, done) ->
			done null, user.id

		passport.deserializeUser (id, done) ->
			client = redis.createClient()
			client.get('user:' + id, (err, user) ->
				if err?
					done err
				
				client.quit()
				done null, JSON.parse(user)
			)
		
	
	init: (app) ->
		app.get '/auth/twitter', passport.authenticate 'twitter'
		app.get '/auth/twitter/callback', passport.authenticate('twitter', {
				successRedirect: '/'
				failureRedirect: '/'
			})
		app.get '/auth/signout', (req, res) ->
			req.logout()
			res.redirect '/'
		
		app.get '/auth/user', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			res.send req.user
		
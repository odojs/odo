define ['module', 'passport', 'passport-twitter', 'odo/config', 'odo/hub', 'node-uuid', 'odo/projections/userprofile', 'odo/projections/usertwitter'], (module, passport, passporttwitter, config, hub, uuid, UserProfile, UserTwitter) ->
	configure: (app) ->
		app.route '/odo', app.modulepath(module.uri) + '/auth-public'
		
		app.use passport.initialize()
		app.use passport.session()
		
		passport.use new passporttwitter.Strategy(
			consumerKey: config.passport.twitter['consumer key']
			consumerSecret: config.passport.twitter['consumer secret']
			callbackURL: config.passport.twitter['host'] + '/auth/twitter/callback'
			passReqToCallback: true
		, (req, token, tokenSecret, profile, done) ->
			userid = null
			
			if req.user?
				console.log 'user already exists, using it\'s id'
				userid = req.user.id
			
			new UserTwitter().get profile.id, (err, userid) ->
				if err?
					done err
					return
				
				if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v1()
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
					console.log 'attaching twitter to user'
					hub.send
						command: 'attachTwitterToUser'
						payload:
							id: userid
							profile: profile
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		)
		
		passport.serializeUser (user, done) ->
			done null, user.id

		passport.deserializeUser (id, done) ->
			new UserProfile().get id, done
		
	
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
		
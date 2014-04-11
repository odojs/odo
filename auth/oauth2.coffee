define [
	'passport'
	'passport-oauth2'
	'odo/config'
	'odo/messaging/hub'
	'node-uuid'
	'redis'
	'odo/express/app'
], (passport, passportoauth2, config, hub, uuid, redis, app) ->
	db = redis.createClient()
	
	class OAuth2Authentication
		web: =>
			passport.use new passportoauth2.Strategy(
				clientID: config.passport.oauth2['client id']
				clientSecret: config.passport.oauth2['client secret']
				callbackURL: config.passport.oauth2['host'] + 'odo/auth/oauth2/callback'
				authorizationURL: config.passport.oauth2['authorization url']
				tokenURL: config.passport.oauth2['token url']
			, (accessToken, refreshToken, profile, done) ->
				console.log 'Found profile!'
				console.log profile
				
				process.nextTick ->
					done null, profile
			)
			
			app.get '/odo/auth/oauth2', passport.authenticate('oauth2')
			app.get '/odo/auth/oauth2/callback', (req, res, next) ->
				passport.authenticate('oauth2', (err, user, info) ->
					return next err if err?
					
					if !user
						if config.odo.auth?.oauth2?.failureRedirect?
							return res.redirect config.odo.auth.oauth2.failureRedirect
						return res.redirect '/#auth/oauth2/failure'
					
					req.logIn user, (err) ->
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if config.odo.auth?.oauth2?.successRedirect?
							return res.redirect config.odo.auth.oauth2.successRedirect
						return res.redirect '/#auth/oauth2/success'
				)(req, res, next)

		projection: =>
			hub.receive 'userOAuth2Connected', (event, cb) =>
				db.hset "#{config.odo.domain}:useroauth2", event.payload.profile.id, event.payload.id, ->
					cb()
			
			hub.receive 'userOAuth2Disconnected', (event, cb) =>
				db.hdel "#{config.odo.domain}:useroauth2", event.payload.profile.id, ->
					cb()
				
		signin: (req, accessToken, refreshToken, profile, done) =>
			userid = null
			
			@get profile.id, (err, userid) =>
				if err?
					done err
					return
				
				if req.user? and userid? and req.user.id isnt userid
					done null, false, { message: 'This OAuth2 account is connected to another Blackbeard account' }
					return
					
				if req.user?
					console.log 'user already exists, connecting OAuth2 to user'
					userid = req.user.id
					hub.send
						command: 'connectOAuth2ToUser'
						payload:
							id: userid
							profile: profile
				
				else if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v1()
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'connectOAuth2ToUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'assignDisplayNameToUser'
						payload:
							id: userid
							displayName: profile.displayName
				
				else
					hub.send
						command: 'connectOAuth2ToUser'
						payload:
							id: userid
							profile: profile
				
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:useroauth2", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				db.hget "#{config.odo.domain}:useroauth2", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data

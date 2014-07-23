define [
	'passport'
	'passport-metocean'
	'odo/config'
	'odo/hub'
	'node-uuid'
	'redis'
	'odo/express'
], (passport, passportmetocean, config, hub, uuid, redis, express) ->
	class MetOceanAuthentication
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
			
		web: =>
			passport.use new passportmetocean.Strategy(
				clientID: config.passport.metocean['client id']
				clientSecret: config.passport.metocean['client secret']
				host: "#{config.metocean.protocol}://#{config.metocean.rootdomain}"
				callbackURL: config.passport.metocean['host'] + 'odo/auth/metocean/callback'
				passReqToCallback: true
			, @signin)
			
			express.get '/odo/auth/metocean', passport.authenticate('metocean')
			express.get '/odo/auth/metocean/callback', (req, res, next) ->
				passport.authenticate('metocean', (err, user, info) ->
					return next err if err?
					
					if !user
						if config.odo.auth?.metocean?.failureRedirect?
							return res.redirect config.odo.auth.metocean.failureRedirect
						return res.redirect '/#auth/metocean/failure'
					
					req.logIn user, (err) ->
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if config.odo.auth?.metocean?.successRedirect?
							return res.redirect config.odo.auth.metocean.successRedirect
						return res.redirect '/#auth/metocean/success'
				)(req, res, next)

		projection: =>
			hub.receive 'userMetOceanConnected', (event, cb) =>
				@db().hset "#{config.odo.domain}:usermetocean", event.payload.profile.id, event.payload.id, ->
					cb()
			
			hub.receive 'userMetOceanDisconnected', (event, cb) =>
				@db().hdel "#{config.odo.domain}:usermetocean", event.payload.profile.id, ->
					cb()
				
		signin: (req, accessToken, refreshToken, profile, done) =>
			userid = null
			
			@get profile.id, (err, userid) =>
				if err?
					done err
					return
				
				if req.user? and userid? and req.user.id isnt userid
					done null, false, { message: 'This MetOcean account is connected to another account' }
					return
					
				if req.user?
					console.log 'user already exists, connecting MetOcean to user'
					userid = req.user.id
					hub.send
						command: 'connectMetOceanToUser'
						payload:
							id: userid
							profile: profile
				
				else if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v4()
					hub.send
						command: 'startTrackingUser'
						payload:
							id: userid
							profile: profile
					
					hub.send
						command: 'connectMetOceanToUser'
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
						command: 'connectMetOceanToUser'
						payload:
							id: userid
							profile: profile
				
				
				user = {
					id: userid
					profile: profile
				}
				
				done null, user
		
		get: (id, callback) ->
			@db().hget "#{config.odo.domain}:usermetocean", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				# retry once for possible slowness
				@db().hget "#{config.odo.domain}:usermetocean", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data

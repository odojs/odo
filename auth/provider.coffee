define [
	'passport'
	'node-uuid'
	'odo/redis'
	'odo/config'
	'odo/hub'
	'odo/express'
], (passport, uuid, redis, config, hub, express) ->
	class ProviderAuthentication
		db: =>
			return @_db if @_db?
			return @_db = redis()
			
		web: =>
			settings = config.odo.auth[@provider]
			
			express.get "/odo/auth/#{@provider}", passport.authenticate @provider
			express.get "/odo/auth/#{@provider}/callback", (req, res, next) =>
				passport.authenticate(@provider, (err, user, info) =>
					throw err if err?
					
					if !user
						if settings.failureRedirect?
							return res.redirect settings.failureRedirect
						return res.redirect "/#auth/#{@provider}/failure"
						
					req.logIn user, (err) =>
						return next err if err?
						
						if req.session?.returnTo?
							returnTo = req.session.returnTo
							delete req.session.returnTo
							return res.redirect returnTo
						if settings.successRedirect?
							return res.redirect settings.successRedirect
						return res.redirect "/#auth/#{@provider}/success"
				)(req, res, next)
				
			express.post "/odo/auth/#{@provider}/disconnect", (req, res) =>
				return res.send 400, 'Id required' if !req.body.id?
				return res.send 400, 'Profile required' if !req.body.profile?
				
				hub.emit "disconnect #{@provider} from user {id}",
					id: req.body.id
					profile: req.body.profile
					
				res.send 'Done'
		
		projection: =>
			hub.every "connect #{@provider} to user {id}", (m, cb) =>
				@db().hset "#{config.odo.domain}:user#{@provider}", m.profile.id, m.id, -> cb()
			
			hub.every "disconnect #{@provider} from user {id}", (m, cb) =>
				@db().hdel "#{config.odo.domain}:user#{@provider}", m.profile.id, -> cb()
				
		signin: (req, accessToken, refreshToken, profile, done) =>
			userid = null
			
			@get profile.id, (err, userid) =>
				return done err if err?
				
				if req.user? and userid? and req.user.id isnt userid
					return done null, false,
						message: "This #{@provider} account is connected to another account"
					
					
				if req.user?
					userid = req.user.id
					hub.emit "connect #{@provider} to user {id}",
						id: userid
						profile: profile
				
				else if !userid?
					console.log 'no user exists yet, creating a new id'
					userid = uuid.v4()
					hub.emit 'start tracking user {id}',
						id: userid
						profile: profile
					
					hub.emit "connect #{@provider} to user {id}",
						id: userid
						profile: profile
					
					hub.emit 'assign displayName {displayName} to user {id}',
						id: userid
						displayName: profile.displayName
				
				else
					hub.emit "connect #{@provider} to user {id}",
						id: userid
						profile: profile
				
				done null,
					id: userid
					profile: profile
		
		get: (id, callback) ->
			@db().hget "#{config.odo.domain}:user#{@provider}", id, (err, data) =>
				return callback err if err?
				return callback null, data if data?
				
				# retry once for possible slowness
				@db().hget "#{config.odo.domain}:user#{@provider}", id, (err, data) =>
					return callback err if err?
					callback null, data

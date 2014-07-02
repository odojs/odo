define [
	'odo/config'
	'odo/hub'
	'odo/eventstore'
	'redis'
	'js-md5'
], (config, hub, es, redis, md5) ->
	class User
		constructor: (id) ->
			@id = id
		
		startTrackingUser: (command, callback) =>
			@new 'userTrackingStarted',
				id: @id,
				profile: command.profile
			callback null
			
			
		assignEmailAddressToUser: (command, callback) =>
			@new 'userHasEmailAddress',
				id: @id,
				email: command.email
			callback null
			
		createVerifyEmailAddressToken: (command, callback) =>
			@new 'userHasVerifyEmailAddressToken',
				id: @id,
				email: command.email
				token: command.token
			callback null
		
		assignDisplayNameToUser: (command, callback) =>
			@new 'userHasDisplayName',
				id: @id,
				displayName: command.displayName
			callback null
		
		assignUsernameToUser: (command, callback) =>
			@new 'userHasUsername',
				id: @id,
				username: command.username
			callback null
			
		
		connectTwitterToUser: (command, callback) =>
			@new 'userTwitterConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectTwitterFromUser: (command, callback) =>
			@new 'userTwitterDisconnected',
				id: @id
				profile: command.profile
			callback null
		
		
		connectFacebookToUser: (command, callback) =>
			@new 'userFacebookConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectFacebookFromUser: (command, callback) =>
			@new 'userFacebookDisconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectGoogleToUser: (command, callback) =>
			@new 'userGoogleConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectGoogleFromUser: (command, callback) =>
			@new 'userGoogleDisconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectOAuth2ToUser: (command, callback) =>
			@new 'userOAuth2Connected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectOAuth2FromUser: (command, callback) =>
			@new 'userOAuth2Disconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectMetOceanToUser: (command, callback) =>
			@new 'userMetOceanConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectMetOceanFromUser: (command, callback) =>
			@new 'userMetOceanDisconnected',
				id: @id
				profile: command.profile
			callback null
			
		
		createLocalSigninForUser: (command, callback) =>
			@new 'userHasLocalSignin',
				id: @id,
				profile: command.profile
			callback null
		
		assignPasswordToUser: (command, callback) =>
			@new 'userHasPassword',
				id: @id,
				password: command.password
			callback null
		
		createPasswordResetToken: (command, callback) =>
			@new 'userHasPasswordResetToken',
				id: @id,
				token: command.token
			callback null
			
		removeLocalSigninForUser: (command, callback) =>
			@new 'userLocalSigninRemoved',
				id: @id
				profile: command.profile
			callback null
	
	class UserApi
		db: =>
			return @_db if @_db?
			return @_db = redis.createClient config.redis.port, config.redis.host
			
		commands: [
			'startTrackingUser'
			'assignEmailAddressToUser'
			'createVerifyEmailAddressToken'
			'assignDisplayNameToUser'
			'assignUsernameToUser'
			
			'connectTwitterToUser'
			'disconnectTwitterFromUser'
			
			'connectFacebookToUser'
			'disconnectFacebookFromUser'
			
			'connectGoogleToUser'
			'disconnectGoogleFromUser'
			
			'connectOAuth2ToUser'
			'disconnectOAuth2FromUser'
			
			'connectMetOceanToUser'
			'disconnectMetOceanFromUser'
			
			'createLocalSigninForUser'
			'assignPasswordToUser'
			'createPasswordResetToken'
			'removeLocalSigninForUser'
		]
		
		defaultHandler: (command) =>
			user = new User command.payload.id
			es.extend user
			user.applyHistoryThenCommand command
		
		domain: =>
			for command in @commands
				hub.handle command, @defaultHandler
		
		projection: =>
			hub.receive 'userTrackingStarted', (event, cb) =>
				user = {
					id: event.payload.id
					# just in case we don't get another opportunity to grab the displayName
					displayName: event.payload.profile.displayName
				}
				
				@db().hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify(user), cb
			
			
			hub.receive 'userHasEmailAddress', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.email = event.payload.email
					user.emailHash = md5 event.payload.email.trim().toLowerCase()
					user
				, cb
			
			hub.receive 'userHasDisplayName', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.displayName = event.payload.displayName
					user
				, cb
			
			hub.receive 'userHasUsername', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					console.log "giving user a username #{event.payload.username}"
					user.username = event.payload.username
					user
				, cb
					

			hub.receive 'userTwitterConnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.twitter =
						id: event.payload.profile.id
						profile: event.payload.profile
					user
				, cb
				
			hub.receive 'userTwitterDisconnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.twitter = null
					user
				, cb
			
			
			hub.receive 'userFacebookConnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.facebook =
						id: event.payload.profile.id
						profile: event.payload.profile
					user
				, cb
				
			hub.receive 'userFacebookDisconnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.facebook = null
					user
				, cb
				
			
			hub.receive 'userGoogleConnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.google =
						id: event.payload.profile.id
						profile: event.payload.profile
					user
				, cb
				
			hub.receive 'userGoogleDisconnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.google = null
					user
				, cb
				
			
			hub.receive 'userMetOceanConnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.metocean =
						id: event.payload.profile.id
						profile: event.payload.profile
					user
				, cb
				
			hub.receive 'userMetOceanDisconnected', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.metocean = null
					user
				, cb
				
				
			hub.receive 'userHasLocalSignin', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.local =
						id: event.payload.id
						profile: event.payload.profile
					user
				, cb
			
			hub.receive 'userHasPassword', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.local.profile.password = event.payload.password
					user
				, cb
			
			hub.receive 'userLocalSigninRemoved', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.local = null
					user
				, cb
		
		addOrRemoveValues: (event, callback, cb) =>
			@db().hget "#{config.odo.domain}:users", event.payload.id, (err, user) =>
				if err?
					cb()
					return
					
				
				user = JSON.parse user
				user = callback user
				user = JSON.stringify user, null, 4
				
				@db().hset "#{config.odo.domain}:users", event.payload.id, user, ->
					cb()
		
		get: (id, callback) =>
			@db().hget "#{config.odo.domain}:users", id, (err, data) =>
				if err?
					callback err
					return
				data = JSON.parse data
				
				if data?
					callback null, data
					return
				
				setTimeout(() =>
					@db().hget "#{config.odo.domain}:users", id, (err, data) =>
						if err?
							callback err
							return
						
						data = JSON.parse data
						callback null, data
				, 1000)
		

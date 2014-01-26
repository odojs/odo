define ['redis', 'odo/infra/config', 'odo/messaging/hub'], (redis, config, hub) ->
	db = redis.createClient()
	
	class UserProfile
		projection: =>
			hub.receive 'userTrackingStarted', (event, cb) =>
				user = {
					id: event.payload.id
					# just in case we don't get another opportunity to grab the displayName
					displayName: event.payload.profile.displayName
				}
				
				db.hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify(user), cb
			
			
			hub.receive 'userHasEmailAddress', (event, cb) =>
				@addOrRemoveValues event, (user) =>
					user.email = event.payload.email
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
			db.hget "#{config.odo.domain}:users", event.payload.id, (err, user) =>
				if err?
					cb()
					return
					
				
				user = JSON.parse user
				user = callback user
				user = JSON.stringify user, null, 4
				
				db.hset "#{config.odo.domain}:users", event.payload.id, user, ->
					cb()
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:users", id, (err, data) =>
				if err?
					callback err
					return
				data = JSON.parse data
				
				if data?
					callback null, data
					return
				
				setTimeout(() =>
					db.hget "#{config.odo.domain}:users", id, (err, data) =>
						if err?
							callback err
							return
						
						data = JSON.parse data
						callback null, data
				, 1000)
				
				
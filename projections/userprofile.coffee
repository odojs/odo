define ['redis', 'odo/config'], (redis, config) ->
	db = redis.createClient()
	
	class UserProfile
		constructor: ->
			@receive =
				userTrackingStarted: (event, cb) =>
					user = {
						id: event.payload.id
						# just in case we don't get another opportunity to grab the displayName
						displayName: event.payload.profile.displayName
					}
					
					db.hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify(user), cb
				
				
				userHasEmailAddress: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.email = event.payload.email
						user
					, cb
				
				userHasDisplayName: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.displayName = event.payload.displayName
						user
					, cb
				
				userHasUsername: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						console.log "giving user a username #{event.payload.username}"
						user.username = event.payload.username
						user
					, cb
						

				userTwitterConnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.twitter =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
					, cb
					
				userTwitterDisconnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.twitter = null
						user
					, cb
				
				
				userFacebookConnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.facebook =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
					, cb
					
				userFacebookDisconnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.facebook = null
						user
					, cb
					
				
				userGoogleConnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.google =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
					, cb
					
				userGoogleDisconnected: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.google = null
						user
					, cb
					
					
				userHasLocalSignin: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.local =
							id: event.payload.id
							profile: event.payload.profile
						user
					, cb
				
				userHasPassword: (event, cb) =>
					@addOrRemoveValues event, (user) =>
						user.local.profile.password = event.payload.password
						user
					, cb
				
				userLocalSigninRemoved: (event, cb) =>
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
				
				
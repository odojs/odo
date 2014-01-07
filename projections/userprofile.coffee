define ['redis', 'odo/config'], (redis, config) ->
	db = redis.createClient()
	
	class UserProfile
		constructor: ->
			@receive =
				userTrackingStarted: (event) =>
					user = {
						id: event.payload.id
						displayName: event.payload.profile.displayName
					}
					
					db.hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify user

				userTwitterAttached: (event) =>
					@addOrRemoveValues event, (user) =>
						user.twitter =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
				
				userFacebookAttached: (event) =>
					@addOrRemoveValues event, (user) =>
						user.facebook =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
				
				userGoogleAttached: (event) =>
					@addOrRemoveValues event, (user) =>
						user.google =
							id: event.payload.profile.id
							profile: event.payload.profile
						user
					
				userHasLocalSignin: (event) =>
					@addOrRemoveValues event, (user) =>
						user.local =
							id: event.payload.id
							profile: event.payload.profile
						user
		
		addOrRemoveValues: (event, callback) =>
			db.hget "#{config.odo.domain}:users", event.payload.id, (err, user) =>
				if err?
					return
				
				user = JSON.parse user
				user = callback user
				user = JSON.stringify user
				
				db.hset "#{config.odo.domain}:users", event.payload.id, user
		
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
				
				
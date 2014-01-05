define ['redis', 'odo/config'], (redis, config) ->
	db = redis.createClient()
	
	class UserProfile
		constructor: ->
			@receive =
				userTrackingStarted: (event) =>
					user = {
						id: event.payload.id
						profile: event.payload.profile
					}
					
					db.hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify user

				userTwitterAttached: (event) =>
					user = {
						id: event.payload.id
						profile: event.payload.profile
					}
					
					db.hset "#{config.odo.domain}:users", event.payload.id, JSON.stringify user
					
				userHasLocalSignin: (event) =>
					db.hget "#{config.odo.domain}:users", event.payload.id, (err, user) =>
						if err?
							return
						
						user = JSON.parse user
						
						user.profile.username = event.payload.profile.username
						user.profile.password = event.payload.profile.password
						
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
				
				
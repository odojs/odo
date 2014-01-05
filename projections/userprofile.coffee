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
				
				
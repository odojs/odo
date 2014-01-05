define ['redis', 'odo/config'], (redis, config) ->
	db = redis.createClient()
	
	class UserTwitter
		constructor: ->
			@receive =
				userTwitterAttached: (event) =>
					console.log 'UserTwitter userTwitterAttached'
					
					db.hset "#{config.odo.domain}:usertwitter", event.payload.profile.id, event.payload.id
		
		get: (id, callback) ->
			db.hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
				if err?
					callback err
					return
					
				if data?
					callback null, data
					return
				
				db.hget "#{config.odo.domain}:usertwitter", id, (err, data) =>
					if err?
						callback err
						return
					
					callback null, data
				
				
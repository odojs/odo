define ['redis'], (redis) ->
	db = redis.createClient()
	
	receive:
		articleCreated: (event) ->
			userid = event.payload.by
			id = event.payload.id
			name = event.payload.name
			
			db.hset "ownedarticles:#{userid}", id, name

		articleDeleted: (event) ->
			userid = event.payload.by
			id = event.payload.id
			
			db.hdel "ownedarticles:#{userid}", id
	
	get: (userid, callback) ->
		db.hgetall "ownedarticles:#{userid}", (err, articles) ->
			if err?
				callback err
				return
			
			callback null, articles
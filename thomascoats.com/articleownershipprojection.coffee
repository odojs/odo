define ['redis'], (redis) ->
	db = redis.createClient()
	
	receive:
		articleCreated: (event) ->
			userid = event.payload.by
			articleid = event.payload.id
			
			db.sadd "ownedarticles:#{userid}", articleid

		articleDeleted: (event) ->
			userid = event.payload.by
			articleid = event.payload.id
			
			db.srem "ownedarticles:#{userid}", articleid
	
	get: (userid, callback) ->
		db.smembers "ownedarticles:#{userid}", (err, articles) ->
			if err?
				callback err
				return
			
			callback null, articles
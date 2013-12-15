define ['redis', 'async'], (redis, async) ->
	# Simple storage for loading, changing and deleting articles
	db = redis.createClient()

	store =
		load: (id, callback) ->
			db.get "readmodel:article:#{id}", (err, data) ->
				callback err if err
				callback null, JSON.parse(data)

		loadAll: (callback) ->
			db.smembers 'readmodel:articles', (err, keys) ->
				callback err if err
				
				
				async.map keys, store.load, (err, items) ->
					callback err if err
					callback null, items

		save: (item, callback) ->
			db.sismember 'readmodel:articles', item.id, (err, exists) ->
				callback err if err
				db.sadd 'readmodel:articles', item.id unless exists
				db.set "readmodel:article:#{item.id}", JSON.stringify(item)
				callback null

		del: (id, callback) ->
			db.srem 'readmodel:articles', id, (err) ->
				callback err if err
				db.del id, (err) ->
					callback err if err
					callback null

	store
define ['redis'], (redis) ->
	db = redis.createClient()
	
	receive:
		articleCreated: (event) ->
			article =
				id: event.payload.id
				name: event.payload.name
			
			db.set "articlecontent:#{article.id}", JSON.stringify article

		articleContentUpdated: (event) ->
			article =
				id: event.payload.id
				content: event.payload.content
				
			db.get "articlecontent:#{article.id}", (err, data) ->
				if err?
					console.log err
					return
				
				data = JSON.parse data
				article.name = data.name
				
				db.set "articlecontent:#{article.id}", JSON.stringify article

		articleDeleted: (event) ->
			article =
				id: event.payload.id
			
			db.del "articlecontent:#{article.id}"
	
	get: (id, callback) ->
		db.get "articlecontent:#{id}", (err, data) ->
			if err?
				callback err
				return
			
			data = JSON.parse data
			
			callback null, data
define ['eventstore', 'eventstore.redis'], (eventstore, storage) ->
	es = eventstore.createStore()
	storage.createStorage (err, store) ->
		es.configure () ->
				es.use store
				#es.use publisher
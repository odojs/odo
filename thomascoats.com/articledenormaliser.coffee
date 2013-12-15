define ['nodecqrs/storage'], (store) ->
	articleCreated: (event) ->
		store.save
			id: event.payload.id
			text: event.payload.text
		, (err) ->

	articlContentUpdated: (event) ->
		store.load event.payload.id, (err, item) ->
			item.text = event.payload.text
			store.save item, (err) ->

	articleDeleted: (event) ->
		store.del event.payload.id, (err) ->
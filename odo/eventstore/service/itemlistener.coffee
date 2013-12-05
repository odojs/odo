define ['storage'], (store) ->
	itemCreated: (evt) ->
		store.save
			id: evt.payload.id
			text: evt.payload.text
		, (err) ->


	itemChanged: (evt) ->
		store.load evt.payload.id, (err, item) ->
			item.text = evt.payload.text
			store.save item, (err) ->



	itemDeleted: (evt) ->
		store.del evt.payload.id, (err) ->
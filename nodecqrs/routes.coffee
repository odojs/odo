define ['nodecqrs/storage'], (store) ->
	init: (app) ->
		app.get '/', (req, res) ->
			res.render 'index'

		app.get '/allItems.json', (req, res) ->
			store.loadAll (err, items) ->
				res.json {} if err
				res.json items
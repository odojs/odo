define ['nodecqrs/storage'], (store) ->
	init: (app) ->
		app.get '/', (req, res) ->
			res.render
				view: 'nodecqrs/layout'
				data:
					title: 'nodecqrs example'
				partials:
					content: 'index'

		app.get '/allItems.json', (req, res) ->
			store.loadAll (err, items) ->
				res.json {} if err
				res.json items
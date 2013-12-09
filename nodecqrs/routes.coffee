define ['module', 'express', 'path', 'nodecqrs/storage'], (module, express, path, store) ->
	
	configure: (app) ->
		app.use '/', express.static(path.join(path.dirname(module.uri), '/public'))
	
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
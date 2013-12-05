define ['module', 'path', 'express', 'odo/eventstore'], (module, path, express, eventstore) ->
	configure: (app) ->
		app.es = eventstore
		
		app.use('/odo', express.static(path.dirname(module.uri) + '/public'))
		
	init: (app) ->
		app.get '/eventstore/test', (req, res) ->
			console.log app.es
			res.send 'totally works'
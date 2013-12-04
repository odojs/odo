define ['module', 'path', 'express', 'redis'], (module, path, express, redis) ->
	configure: (app) ->
		app.use('/eventstore', express.static(path.dirname(module.uri) + '/public'))
		
	init: (app) ->
		app.post '/eventstore/event/:name', (req, res) ->
			console.log "#{req.params.name}"
			res.send 200
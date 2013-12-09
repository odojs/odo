define ['module', 'express', 'path'], (module, express, path) ->
	configure: (app) ->
		app.use('/', express.static(path.dirname(module.uri) + '/public'))
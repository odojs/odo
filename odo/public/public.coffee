define ['module', 'path', 'express'], (module, path, express) ->
	configure: (app) ->
		app.use('/', express.static(path.dirname(module.uri) + '/../../public'))
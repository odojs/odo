define ['module', 'path', 'express'], (module, path, express) ->
	configure: (app) ->
		app.use('/odo/durandal', express.static(path.dirname(module.uri) + '/public'))
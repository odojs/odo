define ['module', 'odo/express'], (module, express) ->
	class Public
		web: =>
			express.route '/', express.modulepath(module.uri) + '/../../public'
			express.route '/odo', express.modulepath(module.uri) + '/public'

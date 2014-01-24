define ['module', 'odo/express/configure'], (module, configure) ->
	class Public
		web: =>
			configure.route '/', configure.modulepath(module.uri) + '/../../../public'
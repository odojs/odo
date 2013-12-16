define ['module'], (module) ->
	configure: (app) ->
		app.route '/odo/durandal', app.modulepath(module.uri) + '/durandal-public'
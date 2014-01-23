define ['module'], (module) ->
	configure: (app) ->
		app.route '/', app.modulepath(module.uri) + '/../../../bower_components'
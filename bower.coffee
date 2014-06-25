define ['module', 'odo/express'], (module, express) ->
	class Bower
		web: ->
			express.route '/bower_components', express.modulepath(module.uri) + '/../../bower_components'

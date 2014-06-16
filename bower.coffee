define ['module', 'odo/express'], (module, express) ->
	class Bower
		web: ->
			express.route '/', express.modulepath(module.uri) + '/../../bower_components'

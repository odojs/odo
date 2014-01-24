define ['module', 'odo/express/configure'], (module, configure) ->
	class Bower
		web: ->
			configure.route '/', configure.modulepath(module.uri) + '/../../../bower_components'
define ['module', 'odo/express/configure'], (module, configure) ->
	class Bower
		web: ->
			configure.route '/', configure.modulepath(module.uri) + '/../../../bower_components'
			configure.route '/odo', configure.modulepath(module.uri) + '/public'
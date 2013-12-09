requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
			domain: './nodecqrs/domain'
		}
}

requirejs ['odo/injectinto', 'nodecqrs/domain/itemcommands', 'odo/hub', 'odo/eventstore'], (inject, itemcommands, hub, eventstore) ->
	
	bindCommands = (handler) ->
		for name, method of handler
			hub.handle name, method
			
	bindCommands itemcommands
requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
		}
}

requirejs ['odo/injectinto', 'thomascoats.com/articlecommands', 'odo/hub', 'odo/eventstore'], (inject, articlecommands, hub, eventstore) ->
	
	bindCommands = (handler) ->
		for name, method of handler
			hub.handle name, method
			
	bindCommands articlecommands
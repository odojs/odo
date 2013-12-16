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

requirejs [
	'odo/hub'
	'thomascoats.com/domain/articlecommands'
	# add more command handlers here
], (hub, handlers...) ->
	
	bindCommands = (handler) ->
		for name, method of handler
			hub.handle name, method
		
	for handler in handlers
		bindCommands handler
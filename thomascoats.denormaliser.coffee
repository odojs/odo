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
	'thomascoats.com/projections/articlecontent'
	'thomascoats.com/projections/articleownership'
	# add more event listeners here
], (hub, listeners...) ->
	
	bindEvents = (listener) ->
		for name, method of listener
			hub.receive name, method
		
	for listener in listeners
		bindEvents listener.receive
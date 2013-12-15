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

requirejs ['odo/injectinto', 'odo/hub', 'thomascoats.com/articledenormaliser'], (inject, hub, articledenormaliser) ->
	
	bindEvents = (listener) ->
		for name, method of listener
			hub.receive name, method
			
	bindEvents articledenormaliser
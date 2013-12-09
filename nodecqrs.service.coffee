requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
			service: './nodecqrs/service'
		}
}

requirejs ['odo/injectinto', 'odo/hub', 'nodecqrs/service/itemevents'], (inject, hub, itemevents) ->
	
	bindEvents = (listener) ->
		for name, method of listener
			hub.receive name, method
			
	bindEvents itemevents
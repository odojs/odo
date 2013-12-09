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

requirejs ['odo/injectinto', 'odo/eventdispatcher', 'nodecqrs/service/itemevents'], (inject, dispatcher, itemevents) ->
	
	bindEvents = (listener) ->
		for name, method of listener
			inject.bind "eventlisteners:#{name}", method
			
	bindEvents itemevents
	
	dispatcher.start()
	console.log 'Starting denormaliser service'
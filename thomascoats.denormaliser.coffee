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
	'thomascoats.com/articlecontentprojection'
	'thomascoats.com/articleownershipprojection'
], (hub, listeners...) ->
	
	bindEvents = (listener) ->
		for name, method of listener
			hub.receive name, method
		
	for listener in listeners
		bindEvents listener.receive
	
	
	fakepublish = (event) ->
		for listener in listeners
			if listener.receive[event.event]?
				listener.receive[event.event] event
	
	
	#fakepublish
	#	event: 'articleCreated'
	#	payload:
	#		id: 'c933e5e8-fb3f-47cb-8690-f634391533d3'
	#		name: 'Test Article'
	#
	#fakepublish
	#	event: 'articleContentUpdated'
	#	payload:
	#		id: 'c933e5e8-fb3f-47cb-8690-f634391533d3'
	#		content: 'Test Article Content'
	
	
		
		
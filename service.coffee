requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
			service: './odo/eventstore/service'
		}
}

requirejs ['service/listener'], (listener) ->
	listener.start()
	console.log 'Starting service'
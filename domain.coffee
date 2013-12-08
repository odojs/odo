requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
			domain: './odo/eventstore/domain'
		}
}

requirejs ['domain/handler'], (handler) ->
	handler.start()
	console.log 'Starting domain service'
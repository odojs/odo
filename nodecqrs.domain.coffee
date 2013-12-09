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

requirejs ['odo/injectinto', 'odo/eventstore/commanddispatcher', 'nodecqrs/domain/itemcommands'], (inject, dispatcher, itemcommands) ->
	
	bindCommands = (handler) ->
		for name, method of handler
			inject.bind "commandhandler:#{name}", method
			
	bindCommands itemcommands
	
	dispatcher.start()
	console.log 'Starting domain service'
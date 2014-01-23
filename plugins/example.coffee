define ['module'], (module) ->
	class Plugin
		# do things that you only need once per use
		constructor: ->
		
		# express configuration / adding functionality
		configure: (app) =>
			app.route '/', app.modulepath(module.uri) + '/plugin-public'
		
		# express application - routes
		init: (app) =>
			app.get '/test', (req, res) =>
				res.send 'Passed'
		
		# listen to events
		receive: (hub) =>
			hub.receive 'testEvent', (event, cb) =>
				console.log 'Test Event Received'
				cb()
		
		# handle commands (generally only domain)
		handle: (hub) =>
			hub.handle 'testCommand', (command) =>
				console.log 'Test Command Received'
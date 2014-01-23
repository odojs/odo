define ['module'], (module) ->
	class ExamplePlugin
		# do things that you only need once per use
		constructor: ->
		
		# express configuration / adding functionality
		configure: (app) =>
			app.route '/', app.modulepath(module.uri) + '/example-public'
			app.durandal 'views/example'
		
		# express application - routes
		init: (app) =>
			app.get '/example', (req, res) =>
				res.send 'Passed'
		
		# listen to events
		receive: (hub) =>
			hub.receive 'exampleEvent', (event, cb) =>
				console.log 'example Event Received'
				cb()
		
		# handle commands (generally only domain)
		handle: (hub) =>
			hub.handle 'exampleCommand', (command) =>
				console.log 'example Command Received'
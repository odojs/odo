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

requirejs ['module', 'http', 'express', 'path', 'peekinto', 'odo/config', 'odo/eventstore/hub', 'socket.io', 'odo/injectinto'], (module, http, express, path, peek, config, hub, socket, inject) ->
	
	app = express()

	# Plugins
	inject.bind 'express:plugins', [
		requirejs './nodecqrs/routes'
		requirejs './nodecqrs/socket'
	]

	# express config
	for key, value of config.express
		app.set key, value

	# Configure express
	app.configure () =>
		# Use default middleware
		#app.use express.logger()
		app.use express.compress()
		app.use express.bodyParser()
		app.use express.methodOverride()
		app.use express.cookieParser app.get 'cookie secret'
		app.use express.cookieSession
			key: app.get 'session key'
			secret: app.get 'session secret'
		app.set 'view engine', 'jade'
		console.log 'Binding'
		console.log path.join(path.dirname(module.uri), '/nodecqrs/views')
		app.set 'views', path.join(path.dirname(module.uri), '/nodecqrs/views')
		
		app.use '/', express.static(path.join(path.dirname(module.uri), '/nodecqrs/public'))
		
		# Peek into a request, perform processing but not be responsible for the output.
		peek app

		# Configure plugins
		for plugin in inject.many 'express:plugins'
			if plugin.configure?
				plugin.configure app
		
		app.use app.router

		# Error handling
		app.use express.errorHandler
			dumpExceptions: true
			showStack: true
	
	server = http.createServer app
	app.io = io = socket.listen server
	
	server.listen(process.env.PORT || 3000)

	# Initialise plugins
	for plugin in inject.many 'express:plugins'
		if plugin.init?
			plugin.init app
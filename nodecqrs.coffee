requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
			plugins: './plugins'
			config: './config'
			odo: './odo'
			service: './odo/eventstore/service'
		}
}

requirejs ['module', 'express', 'path', 'fs', 'peekinto', 'odo/plugins', 'odo/config', 'service/hub', 'http', 'socket.io', 'nodecqrs/routes'], (module, express, path, fs, peek, plugins, config, hub, http, socket, routes) ->
	app = express()

	# Plugins
	#await plugins.loadplugins config.plugins.directories, defer()

	# express config
	for key, value of config.express
		app.set key, value

	# Configure express
	app.configure () =>
		# Use default middleware
		#app.use express.logger()
		#app.use express.compress()
		app.use express.bodyParser()
		#app.use express.methodOverride()
		#app.use express.cookieParser app.get 'cookie secret'
		#app.use express.cookieSession
		#	key: app.get 'session key'
		#	secret: app.get 'session secret'
		app.set 'view engine', 'jade'
		console.log 'Binding'
		console.log path.join(path.dirname(module.uri), '/nodecqrs/views')
		app.set 'views', path.join(path.dirname(module.uri), '/nodecqrs/views')

		# Create configured routes
		#for route in config.routes
		#	app.use route.source, express.static(path.join(path.dirname(module.uri), './', route.target))
		
		app.use '/', express.static(path.join(path.dirname(module.uri), '/nodecqrs/public'))
		
		# Peek into a request, perform processing but not be responsible for the output.
		#peek app

		# Configure plugins
		#await plugins.configure app, defer()
		
		#app.use app.router

		# Error handling
		app.use express.errorHandler
			dumpExceptions: true
			showStack: true
	
	server = http.createServer app
	io = socket.listen server
	
	# BOOTSTRAPPING
	console.log 'BOOTSTRAPPING:'
	console.log '1. -> routes'
	routes app
	console.log '2. -> message hub'

	# SETUP COMMUNICATION CHANNELS

	# on receiving __commands__ from browser via socket.io emit them on the ĥub module (which will 
	# forward it to redis pubsub)
	io.sockets.on 'connection', (socket) ->
		conn = "#{socket.handshake.address.address}:#{socket.handshake.address.port}"
		console.log "#{conn} -- connects to socket.io"
		socket.on 'commands', (data) ->
			console.log "#{conn} -- sends command #{data.command}:"
			console.log JSON.stringify(data, null, 4)
			hub.emit data.command, conn, data



	# on receiving an __event__ from redis via the hub module:
	#
	# - let it be handled from the eventDenormalizer to update the viewmodel storage
	# - forward it to connected browsers via socket.io
	hub.on 'events', (data) ->
		console.log "eventDenormalizer -- denormalize event #{data.event}"
		#handler.handle data, null, 4
		console.log "socket.io -- publish event #{data.event} to browser"
		io.sockets.emit 'events', data
	
	server.listen(process.env.PORT || 3000)

	# Initialise plugins
	await plugins.init app, defer()
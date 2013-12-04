define ['module', 'express', 'path', 'fs', 'peekinto', 'odo/plugins', 'odo/config'], (module, express, path, fs, peek, plugins, config) ->
	(cb) ->
		app = express()

		# Plugins
		await plugins.loadplugins config.plugins.directories, defer()

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

			# Create configured routes
			for route in config.routes
				app.use route.source, express.static(path.join(path.dirname(module.uri), '../', route.target))
			
			# Peek into a request, perform processing but not be responsible for the output.
			peek app

			# Configure plugins
			await plugins.configure app, defer()
			
			app.use app.router

			# Error handling
			app.use express.errorHandler
				dumpExceptions: true
				showStack: true

		app.listen(process.env.PORT || 80)

		# Initialise plugins
		await plugins.init app, defer()
		
		cb app
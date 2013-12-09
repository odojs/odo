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

requirejs ['module', 'express', 'path', 'fs', 'peekinto', 'odo/plugins', 'odo/config'], (module, express, path, fs, peek, plugins, config) ->
	app = express()

	# Plugins
	await plugins.loadplugins ['', 'odo'], defer()

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
		
		
		app.use('/', express.static(path.dirname(module.uri) + '/thomascoats.com/public'))
		
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
define ['http', 'express', 'odo/config'], (http, express, config) ->
	
	(plugins) ->
		app = express()
		
		plugins = plugins.map (plugin) ->
			if typeof(plugin) is 'function'
				return new plugin app
			plugin

		# express config
		for key, value of config.express
			app.set key, value

		# Configure express
		app.configure () =>
			# Use default middleware
			#app.use express.logger()
			app.use express.compress()
			app.use express.urlencoded()
			app.use express.json()
			app.use express.methodOverride()
			app.use express.cookieParser app.get 'cookie secret'
			app.use express.cookieSession
				key: app.get 'session key'
				secret: app.get 'session secret'
			
			app.modulepath = (uri) ->
				items = uri.split '/'
				items.pop()
				items.join '/'
			
			app.route = (source, target) ->
				app.use source, express.static target

			# Configure plugins
			for plugin in plugins
				if plugin.configure?
					plugin.configure app
			
			app.use app.router

			# Error handling
			app.use express.errorHandler
				dumpExceptions: true
				showStack: true
		
		# Put the server on app for extensibility
		app.server = http.createServer app
		app.server.listen(process.env.PORT || 8080)

		# Initialise plugins
		for plugin in plugins
			if plugin.init?
				plugin.init app
				
		app
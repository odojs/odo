define [
	'http'
	'express'
	'odo/config'
	'odo/express/configure'
	'odo/express/express'
	'odo/express/app'
], (http, express, config, _configure, _express, _app) ->
	
	class Express
		constructor: ->
			@app = express()

			# express config
			for key, value of config.express
				@app.set key, value

			# Configure express
			@app.configure () =>
				# Use default middleware
				#app.use express.logger()
				@app.use express.compress()
				@app.use express.urlencoded()
				@app.use express.json()
				@app.use express.methodOverride()
				@app.use express.cookieParser @app.get 'cookie secret'
				@app.use express.cookieSession
					key: @app.get 'session key'
					secret: @app.get 'session secret'
				
				@app.route = (source, target) =>
					@app.use source, express.static target
				
				# Configure plugins
				_express.play @app
				_configure.play @app
				
				@app.use @app.router

				# Error handling
				@app.use express.errorHandler
					dumpExceptions: true
					showStack: true
		
		start: =>
			# Put the server on app for extensibility
			@app.server = http.createServer @app
			@app.server.listen(process.env.PORT || 8080)

			# Initialise plugins
			_app.play @app
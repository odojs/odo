define [
	'odo/config'
	'odo/recorder'
], (config, Recorder) ->
	class Express extends Recorder
		configMethods: [
			'route'
			'use'
		]
		
		appMethods: [
			'get'
			'post'
			'put'
			'delete'
			'engine'
			'set'
		]
		
		constructor: ->
			for method in @configMethods
				@[method] = @_record method
				
			for method in @appMethods
				@[method] = @_record method
			
			super()
		
		modulepath: (uri) ->
			items = uri.split '/'
			items.pop()
			items.join '/'
			
		web: =>
			http = require 'http'
			express = require 'express'
			
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
				if @app.get('upload directory')?
					@app.use express.bodyParser({ uploadDir: @app.get('upload directory') })
				@app.use express.methodOverride()
				@app.use express.cookieParser @app.get 'cookie secret'
				@app.use express.cookieSession
					key: @app.get 'session key'
					secret: @app.get 'session secret'
				if @app.get('allowed cross domains')?
					@app.use (req, res, next) =>
						res.header 'Access-Control-Allow-Origin', @app.get('allowed cross domains')
						res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
						res.header 'Access-Control-Allow-Headers', 'Content-Type'
						next()
				
				@app.route = (source, target) =>
					@app.use source, express.static target
				
				# Configure plugins
				@play @app, @configMethods
				
				@app.use @app.router

				# Error handling
				@app.use express.errorHandler
					dumpExceptions: true
					showStack: true
					
			# Put the server on app for extensibility
			@app.server = http.createServer @app
			port = @app.get('port') || process.env.PORT || 8080
			console.log "Express is listening on port #{port}..."
			@app.server.listen port

			# Initialise plugins
			@play @app, @appMethods
	
	new Express()

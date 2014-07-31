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
			@[method] = @_record method for method in @configMethods
			@[method] = @_record method for method in @appMethods
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
				
			@app.use require('compression')()
			bodyParser = require 'body-parser'
			@app.use bodyParser.urlencoded extended: yes
			@app.use bodyParser.json()
			if @app.get('upload directory')?
				@app.use require('multer')({ dest: @app.get('upload directory') })
			@app.use require('method-override')()
			@app.use require('cookie-parser') @app.get 'cookie secret'
			@app.use require('cookie-session')
				key: @app.get 'session key'
				secret: @app.get 'session secret'
			if @app.get('allowed cross domains')?
				alloweddomains = @app.get('allowed cross domains').split(' ')

				@app.use (req, res, next) =>
					referrer = "#{req.protocol}://#{req.hostname}"
					if req.header('referrer')?
						referrer = req.header('referrer').slice(0,-1)
					
					return next() if not referrer in alloweddomains
					res.header 'Access-Control-Allow-Origin', referrer
					res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
					res.header 'Access-Control-Allow-Headers', 'Content-Type'
					next()
			#@app.use require('morgan')()
			
			@app.route = (source, target) =>
				@app.use source, express.static target
			
			# Configure plugins
			@play @app, @configMethods

			# Error handling
			@app.use require('errorhandler')
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

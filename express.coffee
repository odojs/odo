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
			url = require 'url'
			
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
			if @app.get('use redis sessions')? and @app.get('use redis sessions')
				session = require 'express-session'
				RedisStore = require('connect-redis') session
				sessionOptions =
					secret: @app.get 'session secret'
					saveUninitialized: yes
					resave: yes

				if config.redis.socket?
					sessionOptions.store = new RedisStore
						socket: config.redis.socket
						prefix: "#{config.odo.domain}:sess:"
				else
					sessionOptions.store = new RedisStore
						host: config.redis.host
						port: config.redis.port
						prefix: "#{config.odo.domain}:sess:"
				
				sessionConfig = config.express?.session
				if sessionConfig?
					if sessionConfig.rolling?
						sessionOptions.rolling = sessionConfig.rolling
					if sessionConfig.name?
						sessionOptions.name = sessionConfig.name
					if sessionConfig.cookie?
						sessionOptions.cookie = {}
						for key, value of sessionConfig.cookie
							sessionOptions.cookie[key] = value
				
				@app.use session sessionOptions
			else
				@app.use require('cookie-session')
					key: @app.get 'session key'
					secret: @app.get 'session secret'
			if @app.get('allowed cross domains')?
				alloweddomains = @app.get('allowed cross domains').split ' '

				@app.use (req, res, next) =>
					referrer = "#{req.protocol}://#{req.hostname}"
					if req.header('referer')?
						u = url.parse req.header 'referer'
						referrer = "#{u.protocol}//#{u.host}"  # Protocol includes ':'
					
					return next() unless referrer in alloweddomains
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

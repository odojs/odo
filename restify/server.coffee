define [
	'restify'
	'odo/config'
	'odo/restify/configure'
	'odo/restify/app'
], (restify, config, _configure, _app) ->
	
	class Restify
		api: =>
			@server = restify.createServer()
			_configure.play @server
			_app.play @server
			port = config.restify?.port || process.env.PORT || 8080
			@server.listen port, -> console.log "Restify listening on port #{port}..."

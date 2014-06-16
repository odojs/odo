define [
	'odo/config'
	'odo/recorder'
], (config, Recorder) ->
	class Restify extends Recorder
		constructor: ->
			super [
				'get'
				'post'
				'put'
				'delete'
				'use'
			]
			
		api: =>
			restify = require 'restify'
			server = restify.createServer()
			server.use restify.acceptParser server.acceptable
			server.use restify.authorizationParser()
			server.use restify.dateParser()
			server.use restify.queryParser()
			server.use restify.jsonp()
			server.use restify.gzipResponse()
			server.use restify.bodyParser()
			if config.restify?['allowed cross domains']
				server.use restify.CORS
					origins: config.restify['allowed cross domains'].split ' '
			#server.use restify.throttle
			#	burst: 100
			#	rate: 50
			#	ip: true
			#	overrides:
			#		'192.168.1.1':
			#			rate: 0
			#			burst: 0
			server.use restify.conditionalRequest()
			
			@play server
			port = config.restify?.port || process.env.PORT || 8080
			server.listen port, -> console.log "Restify is listening on port #{port}..."

	new Restify()

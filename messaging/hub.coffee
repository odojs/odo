define ['redis', 'odo/infra/config', 'odo/infra/sequencer'], (redis, config, Sequencer) ->

	commandsender = redis.createClient()
	eventpublisher = redis.createClient()
	
	subscriptions = []
	listeners = {}
	handlers = {}
	
	# The hub encapsulates functionality to send or receive messages from redis.
	result =
		print: ->
			for event, list of listeners
				for listener in list
					console.log "#{event} ->"
					console.log listener.toString()
			
		# send commands to redis __commands channel__
		send: (command) ->
			console.log "#{command.command} -> redis"
			command = JSON.stringify command, null, 4
			commandsender.publish "#{config.odo.domain}.commands", command
			
		handle: (command, callback) ->
			console.log " -> #{command}"
			if handlers[command]?
				console.log "Error, handler already set for #{command}"
				return
			
			handlers[command] = callback
		
		# Don't use this - it's used interally by the event store
		publish: (event) ->
			console.log "#{event.event} -> redis"
			eventpublisher.publish "#{config.odo.domain}.events", JSON.stringify event, null, 4

		receive: (event, callback) ->
			console.log " -> #{event}"
			if !listeners[event]?
				listeners[event] = []
			listeners[event].push callback

		# store subscriptions for a channel (mostly __events__) in a array
		eventstream: (callback) ->
			console.log " -> eventstream"
			subscriptions.push callback
	
	commandreceiver = redis.createClient()
	commandreceiver.on 'message', (channel, command) ->
		command = JSON.parse command
					
		if handlers[command.command]?
			console.log "#{command.command} ->"
			handlers[command.command] command
	
	commandreceiver.subscribe "#{config.odo.domain}.commands"

	# listen to events from redis and call each callback from subscribers
	eventlistener = redis.createClient()
	eventsequencer = new Sequencer()
	ensequence = (event, listener) ->
		eventsequencer.push (cb) ->
			listener event, cb
	eventlistener.on 'message', (channel, event) ->
		event = JSON.parse event
		
		for subscriber in subscriptions
			ensequence event, subscriber
		
		if listeners[event.event]?
			for listener in listeners[event.event]
				console.log "#{event.event} ->"
				ensequence event, listener

	# subscribe to __events channel__
	eventlistener.subscribe "#{config.odo.domain}.events"
	
	result
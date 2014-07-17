define ['redis', 'odo/config', 'odo/sequencer'], (redis, config, Sequencer) ->
	return if ['api', 'web', 'projection', 'domain']
		.filter (n) -> config.contexts.indexOf(n) isnt -1
		.length is 0

	commandsender = redis.createClient config.redis.port, config.redis.host
	eventpublisher = redis.createClient config.redis.port, config.redis.host
	
	subscriptions = []
	listeners = {}
	handlers = {}
	
	# Nice utility method for showing the filename of the code calling the hub. Makes for nice logging.
	getfilename = ->
		return new Error().stack
			# grab the third line - the method that called the method that called this one
			.split('\n')[3]
			# get everything up until the )
			.split(')')[0]
			# get everything after the last /
			.split('/').pop()
			# get the filename and the line number (remove the column number)
			.split(':').splice(0, 2)
			# put the filename and line number back together
			.join(':')
	
	# The hub encapsulates functionality to send or receive messages from redis.
	result =
		print: ->
			for event, list of listeners
				for listener in list
					console.log "#{event} ->"
					console.log listener.toString()
			
		# send commands to redis __commands channel__
		send: (command) ->
			filename = getfilename()
			console.log "#{filename} sending command #{command.command}"
			console.log JSON.stringify command.payload, null, 2
			command = JSON.stringify command, null, 4
			commandsender.publish "#{config.odo.domain}.commands", command
			
		handle: (command, callback) ->
			filename = getfilename()
			# console.log "#{filename} subscribing handler for #{command}"
			if handlers[command]?
				console.log "Error, handler already set for #{command}"
				return
			
			handlers[command] = {
				filename: filename
				callback: callback
			}
		
		# Don't use this - it's used internally by the event store
		publish: (event) ->
			filename = getfilename()
			console.log "#{filename} publishing event #{event.event}"
			console.log JSON.stringify event.payload, null, 2
			eventpublisher.publish "#{config.odo.domain}.events", JSON.stringify event, null, 4

		receive: (event, callback) ->
			filename = getfilename()
			# console.log "#{filename} listening to #{event}"
			if !listeners[event]?
				listeners[event] = []
			listeners[event].push {
				filename: filename
				callback: callback
			}

		# store subscriptions for a channel (mostly __events__) in a array
		eventstream: (callback) ->
			console.log "Subscribing to the eventstream"
			subscriptions.push callback
	
	commandreceiver = redis.createClient config.redis.port, config.redis.host
	commandreceiver.on 'message', (channel, command) ->
		command = JSON.parse command
					
		if handlers[command.command]?
			binding = handlers[command.command]
			console.log "#{binding.filename} handling command #{command.command}"
			console.log JSON.stringify command.payload, null, 2
			binding.callback command
	
	console.log "Subscribing to #{config.odo.domain}.commands redis channel for commands"
	commandreceiver.subscribe "#{config.odo.domain}.commands"

	# listen to events from redis and call each callback from subscribers
	eventlistener = redis.createClient config.redis.port, config.redis.host
	eventsequencer = new Sequencer()
	ensequence = (event, listener) ->
		eventsequencer.push event, (cb) ->
			listener event, cb
	eventlistener.on 'message', (channel, event) ->
		event = JSON.parse event
		
		for subscriber in subscriptions
			ensequence event, subscriber
		
		if listeners[event.event]?
			for listener in listeners[event.event]
				binding = listener
				console.log "#{binding.filename} hearing event #{event.event}"
				console.log JSON.stringify event.payload, null, 2
				ensequence event, binding.callback

	# subscribe to __events channel__
	console.log "Subscribing to #{config.odo.domain}.events redis channel for events"
	eventlistener.subscribe "#{config.odo.domain}.events"
	
	result

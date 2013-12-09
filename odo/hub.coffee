define ['redis', 'eventstore', 'eventstore.redis', 'odo/injectinto'], (redis, eventstore, storage, inject) ->

	# The hub encapsulates functionality to send or receive messages from redis.
	
	# Setup the event store to publish to redis
	es = eventstore.createStore()
	es.configure(->
		eventpublisher = redis.createClient()
		
		es.use
			publish: (event) ->
				console.log 'Publishing event to redis:'
				console.log event
				eventpublisher.publish 'events', JSON.stringify event, null, 4
		es.use storage.createStorage()
	).start()
	
	context =
		applyHistoryThenCommand: (aggregate, command) ->
			es.getEventStream aggregate.id, (err, stream) ->
				console.log "Apply existing events #{stream.events.length}"
				aggregate.loadFromHistory stream.events
				console.log "Apply command #{command.command} to aggregate"
				aggregate[command.command] command.payload, (err, uncommitted) ->
					if err
						console.log err
						return
					
					for event in uncommitted
						stream.addEvent event
					stream.commit()
	
	subscriptions = []
	listeners = {}
	handlers = {}

	commandsender = redis.createClient()
	result =
		# send commands to redis __commands channel__
		send: (commandName, sender, message) ->
			console.log "hub -- publishing command #{commandName} to redis:"
			console.log message
			message = JSON.stringify message, null, 4
			commandsender.publish 'commands', message

		# store subscriptions for a channel (mostly __events__) in a array
		on: (channel, callback) ->
			console.log " -> #{channel}"
			subscriptions.push
				channel: channel
				callback: callback

			console.log "hub -- subscribers: #{subscriptions.length}"

		receive: (event, callback) ->
			console.log " -> #{event}"
			if !listeners[event]?
				listeners[event] = []
			listeners[event].push callback
			
		handle: (command, callback) ->
			console.log " -> #{command}"
			if handlers[command]?
				console.log "Error, handler already set for #{command}"
				return
			
			handlers[command] = callback
			

	eventlistener = redis.createClient()
	# listen to events from redis and call each callback from subscribers
	eventlistener.on 'message', (channel, message) ->
		message = JSON.parse message
		
		subscriptions.forEach (subscriber) ->
			if channel is subscriber.channel
				subscriber.callback message
		
		if channel is 'events' and listeners[message.event]?
			for listener in listeners[message.event]
				listener message

	# subscribe to __events channel__
	eventlistener.subscribe 'events'
	
	
	commandreceiver = redis.createClient()
	commandreceiver.on 'message', (channel, message) ->
		message = JSON.parse message
					
		if channel is 'commands' and handlers[message.command]?
			handlers[message.command] message, context
	
	commandreceiver.subscribe 'commands'
	
	result
define ['redis', 'eventstore', 'eventstore.redis', 'domain/itemcommands'], (redis, eventstore, storage, itemcommands) ->
	start: ->
		# manually bind the command handlers (for now)
		bindings = {}
		addBinding = (binding) ->
			for name, method of binding
				bindings[name] = method
		addBinding itemcommands

		# Setup the event store to publish to redis
		es = eventstore.createStore()
		es.configure(->
			publisher = redis.createClient()
			
			es.use
				publish: (event) ->
					console.log 'Publishing event to redis:'
					console.log event
					publisher.publish 'events', JSON.stringify event, null, 4
			es.use storage.createStorage()
		).start()
		
		# Subscribe to commands and pass them 
		subscriber = redis.createClient()
		subscriber.on 'message', (channel, message) ->
			
			command = JSON.parse(message)
			
			console.log 'Received command from redis:'
			console.log command
			
			if !bindings[command.command]?
				console.log "Could not find a command handler for #{command.command}, this is an error!"
				return
				
			# Give the command handler a context
			bindings[command.command] command.payload,
				applyHistoryThenCommand: (aggregate, callback) ->
					console.log "Load history for id= #{aggregate.id}"
					es.getEventStream aggregate.id, (err, stream) ->
						console.log "Apply existing events #{stream.events.length}"
						aggregate.loadFromHistory stream.events
						console.log "Apply command #{command.command} to aggregate"
						aggregate[command.command] command.payload, (err, uncommitted) ->
							if err
								console.log err
							else
								stream.addEvent uncommitted[0]
								stream.commit()
		subscriber.subscribe 'commands'
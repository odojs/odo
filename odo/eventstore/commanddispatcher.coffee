define ['redis', 'eventstore', 'eventstore.redis', 'odo/injectinto'], (redis, eventstore, storage, inject) ->
	start: ->
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
		
		# Subscribe to commands and pass them 
		subscriber = redis.createClient()
		subscriber.on 'message', (channel, message) ->
			
			command = JSON.parse(message)
			
			console.log 'Received command from redis:'
			console.log command
			
			handler = inject.oneornone "commandhandler:#{command.command}"
			
			if !handler?
				console.log "Could not find a command handler for #{command.command}, this is an error!"
				return
				
			# Give the command handler a context
			handler command, context
		
		subscriber.subscribe 'commands'
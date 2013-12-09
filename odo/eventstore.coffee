define ['node-uuid', 'eventstore', 'eventstore.redis', 'odo/hub'], (uuid, eventstore, storage, hub) ->

	# Setup the event store to publish to redis
	es = eventstore.createStore()
	es.configure(->
		es.use
			publish: hub.publish
		es.use storage.createStorage()
	).start()
	
	extend: (aggregate) ->
		aggregate._uncommitted = []
		
		extensions =
			# Function to reload an itemAggregate from it's past events by applying each event again
			loadFromHistory: (history) ->
				for event in history
					event.payload.fromHistory = true
					@apply event.payload
			
			# Apply the event to the aggregate calling the matching function
			apply: (event) ->
				@["_#{event.event}"] event
				@_uncommitted.push event unless event.fromHistory
				
			# create a new event and apply
			new: (event, payload) ->
				@apply
					id: uuid.v1()
					time: new Date()
					payload: payload
					event: event
			
			applyHistoryThenCommand: (command, callback) ->
				es.getEventStream @id, (err, stream) =>
					console.log "applying #{stream.events.length} events to #{aggregate.id}"
					@loadFromHistory stream.events
					console.log "applying #{command.command}"
					@[command.command] command.payload, (err) =>
						if err
							console.log err
							if callback?
								callback err
							return
						
						for event in @_uncommitted
							stream.addEvent event
						stream.commit()
						@_uncommitted = []
						
						if callback?
							callback null
		
		bind = (method) ->
			() ->
				method.apply aggregate, arguments
		
		for name, method of extensions
			aggregate[name] = bind method
		
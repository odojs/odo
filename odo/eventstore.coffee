define ['eventstore', 'eventstore.redis', 'odo/hub'], (eventstore, storage, hub) ->

	# Setup the event store to publish to redis
	es = eventstore.createStore()
	es.configure(->
		es.use
			publish: hub.publish
		es.use storage.createStorage()
	).start()
	
	applyHistoryThenCommand: (aggregate, command) ->
		es.getEventStream aggregate.id, (err, stream) ->
			console.log "applying #{stream.events.length} events to #{aggregate.id}"
			aggregate.loadFromHistory stream.events
			console.log "applying #{command.command}"
			aggregate[command.command] command.payload, (err, uncommitted) ->
				if err
					console.log err
					return
				
				for event in uncommitted
					stream.addEvent event
				stream.commit()
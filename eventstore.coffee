define ['node-uuid', 'eventstore', 'eventstore.redis', 'odo/hub', 'odo/config'], (uuid, eventstore, storage, hub, config) ->
	return if ['projection', 'domain']
		.filter (n) -> config.contexts.indexOf(n) isnt -1
		.length is 0

	# Setup the event store to publish to redis
	es = eventstore.createStore
		host: config.redis.host
		port: config.redis.port
		
	es.configure(->
		es.use
			publish: hub.publish
		es.use storage.createStorage()
	).start()
	
	getclassname = (constructor) ->
		# function classname(param1, param2) { body }
		constructor
			.toString()
			# function classname
			.split('(')[0]
			# classname
			.split(' ')[1]
	
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
				if @["_#{event.event}"]?
					@["_#{event.event}"] event
				@_uncommitted.push event unless event.fromHistory
				
			# create a new event and apply
			new: (event, payload) ->
				@apply
					id: uuid.v4()
					time: new Date()
					payload: payload
					event: event
			
			applyHistoryThenCommand: (command, callback) ->
				es.getEventStream @id, (err, stream) =>
					# only use the last section of the guid
					identifier = aggregate.id.split('-').pop()
					if @.constructor
						classname = getclassname @.constructor
						identifier = "#{classname} #{identifier}"
					
					#console.log "#{identifier} applying #{stream.events.length} events"
						
					@loadFromHistory stream.events
					#console.log "#{identifier} calling #{command.command}"
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
		

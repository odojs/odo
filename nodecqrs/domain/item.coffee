define ['node-uuid'], (uuid) ->
	# The itemAggregate is the aggregationRoot for a single item all commands concerning this aggregate are handled inside this object. The itemAggregate has an internal state (id, text, destoyed)

	class Item
		constructor: (id) ->
			@id = id
			@text = ''
			@_destroy = false
			@uncommittedEvents = []
			@
			
		# Each __command__ is mapped to an aggregate function
		# After validation the __event__ is applied to the object itself (changing the internal state of the aggregate)
		# When all operations are done the callback will be called. 
		createItem: (command, callback) ->
			if command.text is ''
				callback new Error 'It is not allowed to set an item text to empty string.'
			else
				@apply
					id: uuid.v1()
					time: new Date()
					payload:
						id: @id
						text: command.text
					event: 'itemCreated'
				callback null, @uncommittedEvents

		changeItem: (command, callback) ->
			if command.text is ''
				callback new Error 'It is not allowed to set an item text to empty string.'
			else
				@apply
					id: uuid.v1()
					time: new Date()
					payload:
						id: @id
						text: command.text
					event: 'itemChanged'
				callback null, @uncommittedEvents

		deleteItem: (command, callback) ->
			@apply
				id: uuid.v1()
				time: new Date()
				payload:
					id: @id
					text: @text
				event: 'itemDeleted'
			callback null, @uncommittedEvents

		
		# Apply the event to the aggregate calling the matching function
		apply: (event) ->
			@['_' + event.event] event
			@uncommittedEvents.push event unless event.fromHistory

		_itemCreated: (event) ->
			@text = event.payload.text

		_itemChanged: (event) ->
			@text = event.payload.text

		_itemDeleted: (event) ->
			@_destroy = true

		
		# Function to reload an itemAggregate from it's past events by applying each event again
		loadFromHistory: (history) ->
			for event in history
				event.payload.fromHistory = true
				@apply event.payload
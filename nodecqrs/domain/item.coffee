define [], () ->
	# The itemAggregate is the aggregationRoot for a single item all commands concerning this aggregate are handled inside this object. The itemAggregate has an internal state (id, text, destoyed)

	class Item
		constructor: (id) ->
			@id = id
			@text = ''
			@_destroy = false
			@
			
		# Each __command__ is mapped to an aggregate function
		# After validation the __event__ is applied to the object itself (changing the internal state of the aggregate)
		# When all operations are done the callback will be called. 
		createItem: (command, callback) =>
			if command.text is ''
				callback new Error 'It is not allowed to set an item text to empty string.'
				return
				
			@new 'itemCreated',
				id: @id
				text: command.text
			callback null

		changeItem: (command, callback) =>
			if command.text is ''
				callback new Error 'It is not allowed to set an item text to empty string.'
				return
				
			@new 'itemChanged',
				id: @id
				text: command.text
			callback null

		deleteItem: (command, callback) =>
			@new 'itemDeleted',
				id: @id
				text: @text
			callback null

		_itemCreated: (event) =>
			@text = event.payload.text

		_itemChanged: (event) =>
			@text = event.payload.text

		_itemDeleted: (event) =>
			@_destroy = true
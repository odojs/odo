define ['node-uuid', 'nodecqrs/domain/item'], (uuid, Item) ->
	createItem: (command, context) ->
		id = uuid.v1()
		newId = "item:#{id}"
		item = new Item newId
		context.applyHistoryThenCommand item, command
	
	deleteItem: (command, context) ->
		item = new Item command.payload.id
		context.applyHistoryThenCommand item, command
	
	changeItem: (command, context) ->
		item = new Item command.payload.id
		context.applyHistoryThenCommand item, command
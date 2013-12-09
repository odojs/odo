define ['odo/eventstore', 'node-uuid', 'nodecqrs/domain/item'], (eventstore, uuid, Item) ->
	createItem: (command) ->
		id = uuid.v1()
		newId = "item:#{id}"
		item = new Item newId
		eventstore.applyHistoryThenCommand item, command
	
	deleteItem: (command) ->
		item = new Item command.payload.id
		eventstore.applyHistoryThenCommand item, command
	
	changeItem: (command) ->
		item = new Item command.payload.id
		eventstore.applyHistoryThenCommand item, command
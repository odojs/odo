define ['odo/eventstore', 'node-uuid', 'nodecqrs/domain/item'], (es, uuid, Item) ->
	createItem: (command) ->
		id = uuid.v1()
		newId = "item:#{id}"
		item = new Item newId
		es.extend item
		item.applyHistoryThenCommand command
	
	deleteItem: (command) ->
		item = new Item command.payload.id
		es.extend item
		item.applyHistoryThenCommand command
	
	changeItem: (command) ->
		item = new Item command.payload.id
		es.extend item
		item.applyHistoryThenCommand command
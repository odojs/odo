define ['node-uuid', 'item'], (uuid, Item) ->
	createItem: (command, context) ->
		id = uuid.v1()
		newId = "item:#{id}"
		console.log "create a new aggregate with id= #{newId}"
		item = new Item newId
		context.applyHistoryThenCommand item
	
	deleteItem: (command, context) ->
		item = new Item command.id
		context.applyHistoryThenCommand item
	
	changeItem: (command, context) ->
		item = new Item command.id
		context.applyHistoryThenCommand item
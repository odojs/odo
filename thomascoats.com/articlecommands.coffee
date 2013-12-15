define ['odo/eventstore', 'node-uuid', 'thomascoats.com/article'], (es, uuid, Item) ->
	
	defaultHandler = (command) ->
		updateArticleContent = new Item command.payload.id
		es.extend article
		article.applyHistoryThenCommand command
	
	
	createArticle: defaultHandler
	deleteArticle: defaultHandler
	updateArticleContent: defaultHandler
define ['odo/eventstore', 'node-uuid', 'thomascoats.com/domain/article'], (es, uuid, Article) ->
	
	defaultHandler = (command) ->
		article = new Article command.payload.id
		es.extend article
		article.applyHistoryThenCommand command
	
	
	createArticle: defaultHandler
	deleteArticle: defaultHandler
	updateArticleContent: defaultHandler
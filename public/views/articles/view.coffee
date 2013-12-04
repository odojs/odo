define ['knockout', 'jquery', 'articles/client', 'plugins/router'], (ko, $, ArticleLogic, router) ->
	class ViewArticle
		constructor: ->
			@article = ko.observable null
			@articleLogic = new ArticleLogic()
		
		canActivate: (id, name) =>
			$.Deferred((deferred) =>
				@articleLogic.getArticleForDisplay(id)
					.then(-> deferred.resolve yes)
					.fail(-> deferred.resolve no)
			).promise()
		
		activate: (id, name) =>
			$.Deferred((deferred) =>
				@articleLogic.getArticleForDisplay(id)
					.then((article) =>
					
						@article {
							id: ko.observable article.id
							name: ko.observable article.name
							url: ko.observable article.url
						}
						
						deferred.resolve yes
					)
					.fail(=> deferred.resolve no)
			).promise()
			
		deleteArticle: =>
			@articleLogic.deleteArticle(@article().id())
				.then =>
					router.navigate ''
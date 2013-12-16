define ['q', 'knockout', 'articles', 'plugins/router'], (Q, ko, ArticleLogic, router) ->
	class ViewArticle
		constructor: ->
			@article = ko.observable null
			@articleLogic = new ArticleLogic()
		
		canActivate: (id, name) =>
			dfd = Q.defer()
			@articleLogic.getArticleForDisplay(id)
				.then(->
					dfd.resolve yes)
				.fail((err) ->
					dfd.resolve no)
			dfd.promise
		
		activate: (id, name) =>
			dfd = Q.defer()
			@articleLogic.getArticleForDisplay(id)
				.then((article) =>
				
					@article {
						id: ko.observable article.id
						name: ko.observable article.name
						url: ko.observable article.url
					}
					
					dfd.resolve yes
				)
				.fail(=> dfd.resolve no)
			
		deleteArticle: =>
			@articleLogic.deleteArticle(@article().id())
				.then =>
					router.navigate ''
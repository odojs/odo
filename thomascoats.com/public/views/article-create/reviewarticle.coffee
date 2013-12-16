define ['knockout', 'articles'], (ko, ArticleLogic) ->
	class ReviewArticle
		constructor: ->
			@articlename = ko.observable ''
			@area = ko.observable ''
			@articleLogic = new ArticleLogic()
			
		activate: (options) =>
			{ @wizard, @dialog, activationData } = options
			@articlename activationData.name
			@area activationData.area
		
		submit: =>
			article = {
				name: @articlename()
				area: @area()
			}
			@articleLogic.createArticle(article)
				.then =>
					@close article
		
		close: (response) =>
			@dialog.close(response)
			
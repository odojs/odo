define ['q', 'knockout', 'plugins/router', 'components/dialog', 'articles', 'odo/auth/twitter'], (Q, ko, router, Dialog, ArticleLogic, twitterauth) ->
	class Search
		constructor: ->
			@articles = ko.observableArray []
			@selectedIndex = ko.observable 0
			@refineByText = ko.observable ''
			@refinedArticles = ko.computed( =>
				@selectedIndex 0
				articles = @articles()
				refineByText = @refineByText().toLowerCase()
				if refineByText is ''
					return []
				articles.filter((article) =>
					article.name.toLowerCase().indexOf(refineByText) is 0
				)
				
				
			, @)
			@limitedArticles = ko.computed( =>
				@refinedArticles().slice(0, 10)
			)
			@hasMore = ko.computed( =>
				@refinedArticles().length > @limitedArticles().length
			, @)
			@shouldShake = ko.observable no
			@hasFocus = ko.observable yes
			@articleLogic = new ArticleLogic()
		
		canActivate: =>
			dfd = Q.defer()
			twitterauth.getUser()
				.then(->
					dfd.resolve yes
				)
				.fail(->
					dfd.resolve {
						redirect: '#welcome'
					}
				)
			dfd.promise
		
		activate: =>
			dfd = Q.defer()
			@articleLogic.getArticlesForAutocomplete()
				.then((articles) =>
					for article in articles
						@articles.push article
					dfd.resolve()
				)
				.fail((err) => dfd.reject err)
				
			dfd.promise
			
		up: =>
			index = @selectedIndex()
			index--
			if index < 0
				index = @limitedArticles().length - 1
			@selectedIndex index
			
		down: =>
			index = @selectedIndex()
			index++
			index = index % @limitedArticles().length
			@selectedIndex index
		
		submit: =>
			@hasFocus no
			
			# selected autocomplete? Open that
			if @selectedIndex() < @limitedArticles().length
				article = @limitedArticles()[@selectedIndex()]
				router.navigate @articleLogic.getUrlForArticle article
				return no
			
			# nothing typed? Shake that
			articleName = @refineByText().trim()
			if articleName is ''
				@hasFocus yes
				@shake()
				return no
			
			# typed some characters? New that
			options = {
				model: 'components/wizard'
				activationData: {
					model: 'views/article-create/selectlocation'
					activationData: articleName
				}
			}
			
			new Dialog(options).show().then (article) =>
				if article?
					router.navigate @articleLogic.getUrlForArticle article
					
			no
		
		selectArticle: (article) =>
			index = @limitedArticles().indexOf article
			@selectedIndex index
			@submit()
		
		shake: =>
			@shouldShake yes
			
			setTimeout(() =>
				@shouldShake no
			, 1000)
			
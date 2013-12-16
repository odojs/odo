define ['q', 'jquery', 'odo/auth/twitter', 'uuid'], (Q, $, twitterauth, uuid) ->
	areas = [
		'Patterns & Practices'
		'Leader of Men'
	]
	
	class ArticleLogic
		constructor: ->
	
		getArticlesForAutocomplete: =>
			twitterauth.getUser()
				.then((user) ->
					Q($.get("user/#{user.id}/articles"))
						.then((articles) =>
							articles = articles.sort (a, b) ->
								a = a.name.toLowerCase()
								b = b.name.toLowerCase()
								
								return -1 if a < b
								return 1 if a > b
								0
							articles
						)
				)
		
		getArticleForDisplay: (id) =>
			Q($.get("article/#{id}"))
				.then((article) =>
					article.url = @getUrlForArticle article
					article
				)
		
		getAreasForAutocomplete: =>
			dfd = Q.defer()
			dfd.resolve areas
			dfd.promise
		
		getUrlForArticle: (article) =>
			"articles/#{article.id}/#{article.name}"
		
		createArticle: (article) =>
			article.id = uuid.v1()
			Q($.post("article/#{article.id}", article))
		
		deleteArticle: (id) =>
			Q($.ajax({
				url: "article/#{id}"
				type: 'DELETE'
			}))
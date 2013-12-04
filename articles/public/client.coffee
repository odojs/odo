define ['jquery', 'odo/auth/twitter', 'uuid'], ($, twitterauth, uuid) ->
	areas = [
		'Patterns & Practices'
		'Leader of Men'
	]
	
	class ArticleLogic
		constructor: ->
	
		getArticlesForAutocomplete: =>
			$.Deferred((deferred) =>
				twitterauth.getUser (err, user) ->
					if err?
						deferred.reject err
						return
					
					$.get("user/#{user.id}/articles")
						.then((articles) =>
							articles = articles.sort (a, b) ->
								a = a.name.toLowerCase()
								b = b.name.toLowerCase()
								
								return -1 if a < b
								return 1 if a > b
								0
							deferred.resolve articles
						)
						.fail((xhr, err) => deferred.reject err)
			).promise()
		
		getArticleForDisplay: (id) =>
			$.Deferred((deferred) =>
				$.get("article/#{id}")
					.then((article) =>
						article.url = @getUrlForArticle article
						deferred.resolve article
					)
					.fail((xhr, err) => deferred.reject err)
			).promise()
		
		getAreasForAutocomplete: =>
			$.Deferred((deferred) =>
				deferred.resolve areas
			).promise()
		
		getUrlForArticle: (article) =>
			"articles/#{article.id}/#{article.name}"
		
		createArticle: (article) =>
			$.Deferred((deferred) =>
				article.id = uuid.v1()
				$.post("article/#{article.id}", article)
					.then(=> deferred.resolve())
					.fail((xhr, err) => deferred.reject err)
			).promise()
		
		deleteArticle: (id) =>
			$.Deferred((deferred) =>
				$.ajax({
					url: "article/#{id}"
					type: 'DELETE'
				})
					.then(=> deferred.resolve())
					.fail((xhr, err) => deferred.reject err)
			).promise()
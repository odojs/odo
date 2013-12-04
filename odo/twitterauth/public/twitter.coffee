define ['jquery'], ($) ->
	cache = null
	
	getUser: (done) =>
		if @cache?
			done null, @cache
		$.get('/auth/user').then((data) ->
			@cache = data
			done null, data
		).fail((xhr, err) ->
			done err
		)
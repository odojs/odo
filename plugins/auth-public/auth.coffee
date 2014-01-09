define ['jquery', 'q'], ($, Q) ->
	cache = null
	
	getUser: () =>
		dfd = Q.defer()
		
		if @cache?
			dfd.resolve @cache
		Q($.get('/odo/auth/user'))
			.then((data) =>
				@cache = data
				dfd.resolve data
			)
			.fail(->
				dfd.reject())
			
		dfd.promise
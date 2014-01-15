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
		
	assignUsernameToUser: (id, username) =>
		$.post '/sendcommand/assignUsernameToUser',
			id: id
			username: username
	
	assignDisplayNameToUser: (id, displayName) =>
		$.post '/sendcommand/assignDisplayNameToUser',
			id: id
			displayName: displayName
	
	assignEmailAddressToUser: (id, email) =>
		$.post '/sendcommand/assignEmailAddressToUser',
			id: id
			email: email
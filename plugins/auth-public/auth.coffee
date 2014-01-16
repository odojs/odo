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
			
	getUsernameAvailability: (username) =>
		$.get '/odo/auth/local/usernameavailability',
			username: username
	
	testAuthentication: (username, password) =>
		$.get '/odo/auth/local/test', 
			username: username
			password: password
	
	assignPasswordToUser: (id, password) =>
		$.post '/sendcommand/assignPasswordToUser',
			id: id
			password: password
	
	disconnectTwitterFromUser: (id, profile) =>
		$.post '/sendcommand/disconnectTwitterFromUser',
			id: id
			profile: profile
	
	disconnectFacebookFromUser: (id, profile) =>
		$.post '/sendcommand/disconnectFacebookFromUser',
			id: id
			profile: profile
	
	disconnectGoogleFromUser: (id, profile) =>
		$.post '/sendcommand/disconnectGoogleFromUser',
			id: id
			profile: profile
	
	removeLocalSigninForUser: (id, profile) =>
		$.post '/sendcommand/removeLocalSigninForUser',
			id: id
			profile: profile
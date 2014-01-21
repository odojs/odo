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
			.fail(-> dfd.reject())
			
		dfd.promise
		
	assignUsernameToUser: (id, username) =>
		Q $.post '/sendcommand/assignUsernameToUser',
			id: id
			username: username
	
	assignDisplayNameToUser: (id, displayName) =>
		Q $.post '/sendcommand/assignDisplayNameToUser',
			id: id
			displayName: displayName
	
	createVerifyEmailAddressToken: (email) =>
		Q $.post '/odo/auth/verifyemail',
			email: email
		
	checkEmailVerificationToken: (email, token) =>
		Q $.get '/odo/auth/checkemailverificationtoken',
			email: email
			token: token
	
	assignEmailAddressToUserWithToken: (email, token) =>
		Q $.post '/odo/auth/emailverified',
			email: email
			token: token
			
	getUsernameAvailability: (username) =>
		Q $.get '/odo/auth/local/usernameavailability',
			username: username
	
	testAuthentication: (username, password) =>
		Q $.get '/odo/auth/local/test', 
			username: username
			password: password
	
	assignPasswordToUser: (id, password) =>
		Q $.post '/sendcommand/assignPasswordToUser',
			id: id
			password: password
	
	disconnectTwitterFromUser: (id, profile) =>
		Q $.post '/sendcommand/disconnectTwitterFromUser',
			id: id
			profile: profile
	
	disconnectFacebookFromUser: (id, profile) =>
		Q $.post '/sendcommand/disconnectFacebookFromUser',
			id: id
			profile: profile
	
	disconnectGoogleFromUser: (id, profile) =>
		Q $.post '/sendcommand/disconnectGoogleFromUser',
			id: id
			profile: profile
	
	removeLocalSigninForUser: (id, profile) =>
		Q $.post '/sendcommand/removeLocalSigninForUser',
			id: id
			profile: profile
	
	forgotCheckEmailAddress: (email) =>
		Q $.get '/odo/auth/forgot',
			email: email
		
	createPasswordResetToken: (email) =>
		Q $.post '/odo/auth/local/resettoken',
			email: email
	
	checkResetToken: (token) =>
		Q $.get '/odo/auth/local/resettoken',
			token: token
	
	resetPasswordWithToken: (token, password) =>
		Q $.post '/odo/auth/local/reset',
			token: token
			password: password
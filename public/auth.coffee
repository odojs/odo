define 'odo/auth', ['jquery', 'q'], ($, Q) ->
	cache = null
	
	getUser: () =>
		dfd = Q.defer()
		
		if @cache?
			dfd.resolve @cache
		else
			Q($.get('/odo/auth/user'))
				.then((data) =>
					if !data? or data is ''
						return dfd.reject()
					@cache = data
					dfd.resolve data
				)
				.fail(-> dfd.reject())
			
		dfd.promise
		
	assignUsernameToUser: (id, username) =>
		Q $.post '/odo/auth/local/assignusername',
			id: id
			username: username
	
	assignPasswordToUser: (id, password) =>
		Q $.post '/odo/auth/local/assignpassword',
			id: id
			password: password
	
	assignDisplayNameToUser: (id, displayName) =>
		Q $.post '/odo/auth/assigndisplayname',
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

	getEmailAvailability: (email) =>
		Q $.get '/odo/auth/local/emailavailability',
			email: email

	testAuthentication: (username, password) =>
		Q $.get '/odo/auth/local/test', 
			username: username
			password: password
	
	disconnectTwitterFromUser: (id, profile) =>
		Q $.post '/odo/auth/twitter/disconnect',
			id: id
			profile: profile
	
	disconnectFacebookFromUser: (id, profile) =>
		Q $.post '/odo/auth/facebook/disconnect',
			id: id
			profile: profile
	
	disconnectGoogleFromUser: (id, profile) =>
		Q $.post '/odo/auth/google/disconnect',
			id: id
			profile: profile
	
	removeLocalSigninForUser: (id, profile) =>
		Q $.post '/odo/auth/local/remove',
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

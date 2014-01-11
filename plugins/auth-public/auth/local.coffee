define ['jquery'], ($) ->
	getUsernameAvailability: (username) =>
		$.get '/odo/auth/local/usernameavailability',
			username: username
	
	testAuthentication: (username, password) =>
		$.get '/odo/auth/local/test', 
			username: username
			password: password
define ['jquery'], ($) ->
	getUsernameAvailability: (username) =>
		$.get '/odo/auth/local/usernameavailability',
			username: username
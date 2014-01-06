define [], () ->
	class User
		constructor: (id) ->
			@id = id
		
		startTrackingUser: (command, callback) =>
			@new 'userTrackingStarted',
				id: @id,
				profile: command.profile
			callback null
		
		attachTwitterToUser: (command, callback) =>
			@new 'userTwitterAttached',
				id: @id,
				profile: command.profile
			callback null
		
		attachFacebookToUser: (command, callback) =>
			@new 'userFacebookAttached',
				id: @id,
				profile: command.profile
			callback null
			
		attachGoogleToUser: (command, callback) =>
			@new 'userGoogleAttached',
				id: @id,
				profile: command.profile
			callback null
		
		createLocalSigninForUser: (command, callback) =>
			@new 'userHasLocalSignin',
				id: @id,
				profile: command.profile
			callback null
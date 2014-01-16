define [], () ->
	class User
		constructor: (id) ->
			@id = id
		
		startTrackingUser: (command, callback) =>
			@new 'userTrackingStarted',
				id: @id,
				profile: command.profile
			callback null
			
			
		assignEmailAddressToUser: (command, callback) =>
			@new 'userHasEmailAddress',
				id: @id,
				email: command.email
			callback null
		
		assignDisplayNameToUser: (command, callback) =>
			@new 'userHasDisplayName',
				id: @id,
				displayName: command.displayName
			callback null
		
		assignUsernameToUser: (command, callback) =>
			@new 'userHasUsername',
				id: @id,
				username: command.username
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
		
		assignPasswordToUser: (command, callback) =>
			@new 'userHasPassword',
				id: @id,
				password: command.password
			callback null
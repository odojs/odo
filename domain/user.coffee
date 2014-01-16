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
			
		
		connectTwitterToUser: (command, callback) =>
			@new 'userTwitterConnected',
				id: @id,
				profile: command.profile
			callback null
		
		connectFacebookToUser: (command, callback) =>
			@new 'userFacebookConnected',
				id: @id,
				profile: command.profile
			callback null
			
		connectGoogleToUser: (command, callback) =>
			@new 'userGoogleConnected',
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
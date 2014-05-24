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
			
		createVerifyEmailAddressToken: (command, callback) =>
			@new 'userHasVerifyEmailAddressToken',
				id: @id,
				email: command.email
				token: command.token
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
			
		disconnectTwitterFromUser: (command, callback) =>
			@new 'userTwitterDisconnected',
				id: @id
				profile: command.profile
			callback null
		
		
		connectFacebookToUser: (command, callback) =>
			@new 'userFacebookConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectFacebookFromUser: (command, callback) =>
			@new 'userFacebookDisconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectGoogleToUser: (command, callback) =>
			@new 'userGoogleConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectGoogleFromUser: (command, callback) =>
			@new 'userGoogleDisconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectOAuth2ToUser: (command, callback) =>
			@new 'userOAuth2Connected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectOAuth2FromUser: (command, callback) =>
			@new 'userOAuth2Disconnected',
				id: @id
				profile: command.profile
			callback null
			
			
		connectMetOceanToUser: (command, callback) =>
			@new 'userMetOceanConnected',
				id: @id,
				profile: command.profile
			callback null
			
		disconnectMetOceanFromUser: (command, callback) =>
			@new 'userMetOceanDisconnected',
				id: @id
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
		
		createPasswordResetToken: (command, callback) =>
			@new 'userHasPasswordResetToken',
				id: @id,
				token: command.token
			callback null
			
		removeLocalSigninForUser: (command, callback) =>
			@new 'userLocalSigninRemoved',
				id: @id
				profile: command.profile
			callback null

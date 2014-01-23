define ['odo/infra/eventstore', 'odo/domain/user'], (es, User) ->
	
	defaultHandler = (command) ->
		user = new User command.payload.id
		es.extend user
		user.applyHistoryThenCommand command
	
	handle: (hub) ->
		commands = [
			'startTrackingUser'
			'assignEmailAddressToUser'
			'createVerifyEmailAddressToken'
			'assignDisplayNameToUser'
			'assignUsernameToUser'
			
			'connectTwitterToUser'
			'disconnectTwitterFromUser'
			
			'connectFacebookToUser'
			'disconnectFacebookFromUser'
			
			'connectGoogleToUser'
			'disconnectGoogleFromUser'
			
			'createLocalSigninForUser'
			'assignPasswordToUser'
			'createPasswordResetToken'
			'removeLocalSigninForUser'
		]
		
		for command in commands
			hub.handle command, defaultHandler
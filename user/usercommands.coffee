define ['odo/infra/hub', 'odo/infra/eventstore', 'odo/user/user'], (hub, es, User) ->
	class UserCommands
		commands: [
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
		
		defaultHandler: (command) =>
			user = new User command.payload.id
			es.extend user
			user.applyHistoryThenCommand command
		
		domain: =>
			for command in @commands
				hub.handle command, @defaultHandler
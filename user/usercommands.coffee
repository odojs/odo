define ['odo/messaging/hub', 'odo/messaging/eventstore', 'odo/user/user'], (hub, es, User) ->
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
			
			'connectOAuth2ToUser'
			'disconnectOAuth2FromUser'
			
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

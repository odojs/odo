define ['odo/eventstore', 'odo/domain/user'], (es, User) ->
	
	defaultHandler = (command) ->
		user = new User command.payload.id
		es.extend user
		user.applyHistoryThenCommand command
	
	startTrackingUser: defaultHandler
	assignEmailAddressToUser: defaultHandler
	assignDisplayNameToUser: defaultHandler
	assignUsernameToUser: defaultHandler
	
	connectTwitterToUser: defaultHandler
	disconnectTwitterFromUser: defaultHandler
	
	connectFacebookToUser: defaultHandler
	disconnectFacebookFromUser: defaultHandler
	
	connectGoogleToUser: defaultHandler
	disconnectGoogleFromUser: defaultHandler
	
	createLocalSigninForUser: defaultHandler
	assignPasswordToUser: defaultHandler
	createPasswordResetToken: defaultHandler
	removeLocalSigninForUser: defaultHandler
define ['odo/eventstore', 'odo/domain/user'], (es, User) ->
	
	defaultHandler = (command) ->
		user = new User command.payload.id
		es.extend user
		user.applyHistoryThenCommand command
	
	startTrackingUser: defaultHandler
	attachTwitterToUser: defaultHandler
	createLocalSigninForUser: defaultHandler
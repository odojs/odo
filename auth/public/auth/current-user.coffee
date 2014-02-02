defineQ ['q', 'odo/auth'], (Q, auth) ->
	dfd = Q.defer()
	auth
		.getUser()
		.then((user) ->
			dfd.resolve user)
		.fail((err) ->
			dfd.resolve null)
	dfd.promise
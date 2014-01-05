define ['passport', 'passport-local', 'odo/config', 'odo/hub', 'node-uuid', 'redis', 'odo/projections/userprofile'], (passport, passportlocal, config, hub, uuid, redis, UserProfile) ->
	db = redis.createClient()
	
	class LocalAuthentication
		constructor: ->
			@receive =
				userHasLocalSignin: (event) =>
					console.log 'LocalAuthentication userHasLocalSignin'
					
					db.hset "#{config.odo.domain}:localusers", event.payload.profile.username, event.payload.id
		
		configure: (app) =>
			passport.use new passportlocal.Strategy (username, password, done) =>
				userid = null
				
				@get username, (err, userid) =>
					if err?
						done err
						return
					
					# Use this code for signup - first command if this is a new user, second command for both new user and to link an existing user to a local sign in account. Creating a new user needs more information - displayName, etc.
					#if !userid?
					#	console.log 'no user exists yet, creating a new id'
					#	userid = uuid.v1()
					#	hub.send
					#		command: 'startTrackingUser'
					#		payload:
					#			id: userid
					#			profile:
					#				username: username
					#				password: password
					#	
					#	console.log 'attaching twitter to user'
					#	hub.send
					#		command: 'createLocalSigninForUser'
					#		payload:
					#			id: userid
					#			profile:
					#				username: username
					#				password: password
					
					
					if !userid?
						console.log 'User not found'
						done null, false, { message: 'Incorrect username or password.' }
						return
					
					new UserProfile().get userid, (err, user) =>
						if err?
							done err
							return
					
						if user.profile.password isnt password
							console.log 'Password not correct'
							done null, false, { message: 'Incorrect username or password.' }
							return
						
						console.log 'Returning successfully'
						done null, user
			
		init: (app) =>
			app.post '/auth/local', passport.authenticate('local', {
				successRedirect: '/'
				failureRedirect: '/'
			})
		
		get: (username, callback) ->
			console.log 
			
			db.hget "#{config.odo.domain}:localusers", username, (err, data) =>
				if err?
					callback err
					return
					
				callback null, data
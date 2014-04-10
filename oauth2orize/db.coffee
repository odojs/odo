define [], () ->
	class AccessTokens
		constructor: ->
			@tokens = {}
		
		find: (key, done) =>
			token = @tokens[key]
			done null, token
		
		save: (token, userID, clientID, done) =>
			@tokens[token] =
				userID: userID
				clientID: clientID

			done null

	class AuthorisationCodes
		constructor: ->
			@codes = {}

		find: (key, done) =>
			code = @codes[key]
			done null, code
		
		save: (code, clientID, redirectURI, userID, done) =>
			@codes[code] =
				clientID: clientID
				redirectURI: redirectURI
				userID: userID

			done null
		
		delete: (key, done) =>
			delete @codes[key]

			done null

	class Clients
		constructor: ->
			@clients = [
				id: '1'
				name: 'Samplr'
				clientId: 'abc123'
				clientSecret: 'ssh-secret'
			]
		
		find: (id, done) =>
			i = 0
			len = @clients.length

			while i < len
				client = @clients[i]
				return done(null, client)  if client.id is id
				i++
			done null, null

		findByClientId: (clientId, done) =>
			i = 0
			len = @clients.length

			while i < len
				client = @clients[i]
				return done(null, client)  if client.clientId is clientId
				i++
			
			done null, null
	
	return {
		clients: new Clients()
		accessTokens: new AccessTokens()
		authorizationCodes: new AuthorisationCodes()
	}

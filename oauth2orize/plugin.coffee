define [
	'odo/express/app'
	'odo/oauth2orize/db'
	'odo/oauth2orize/server'
	'odo/config'
	'oauth2orize'
	'passport'
	'passport-local'
	'passport-http'
	'passport-oauth2-client-password'
	'passport-http-bearer'
	'connect-ensure-login'
],
(
	app,
	db,
	server,
	config,
	oauth2orize,
	passport,
	passportlocal,
	passportbasic,
	passportclientpassword,
	passportbearer,
	login
) ->
	class OAuth2
		getRandomInt: (min, max) =>
			Math.floor(Math.random() * (max - min + 1)) + min
			
		uid: (len) =>
			buf = []
			chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
			charlen = chars.length
			i = 0

			while i < len
			 buf.push chars[@getRandomInt(0, charlen - 1)]
			 i++
			buf.join ''
		
		web: =>
			###
			BasicStrategy & ClientPasswordStrategy

			These strategies are used to authenticate registered OAuth clients. They are
			employed to protect the `token` endpoint, which consumers use to obtain
			access tokens. The OAuth 2.0 specification suggests that clients use the
			HTTP Basic scheme to authenticate. Use of the client password strategy
			allows clients to send the same credentials in the request body (as opposed
			to the `Authorization` header). While this approach is not recommended by
			the specification, in practice it is quite common.
			###
			passport.use new passportbasic.BasicStrategy((username, password, done) ->
				db.clients.findByClientId username, (err, client) ->
					return done(err) if err
					return done(null, false) unless client
					return done(null, false) unless client.clientSecret is password
					done null, client
			)
			passport.use new passportclientpassword.Strategy((clientId, clientSecret, done) ->
				db.clients.findByClientId clientId, (err, client) ->
					return done(err) if err
					return done(null, false) unless client
					return done(null, false) unless client.clientSecret is clientSecret
					done null, client
			)

			###
			BearerStrategy

			This strategy is used to authenticate users based on an access token (aka a
			bearer token). The user must have previously authorized a client
			application, which is issued an access token to make requests on behalf of
			the authorizing user.
			###
			passport.use new passportbearer.Strategy((accessToken, done) ->
				db.accessTokens.find accessToken, (err, token) ->
					return done(err) if err
					return done(null, false) unless token
					new UserProfile().get token.userID, (err, user) ->
						return done(err) if err
						return done(null, false) unless user
						
						# to keep this example simple, restricted scopes are not implemented,
						# and this is just for illustrative purposes
						info = scope: '*'
						done null, user, info
			)

			# Register serialialization and deserialization functions.
			#
			# When a client redirects a user to user authorization endpoint, an authorization transaction is initiated. To complete the transaction, the user must authenticate and approve the authorization request. Because this may involve multiple HTTP request/response exchanges, the transaction is stored in the session.
			#
			# An application must supply serialization functions, which determine how the client object is serialized into the session. Typically this will be a simple matter of serializing the client's ID, and deserializing by finding the client by ID from the database.
			server.serializeClient (client, done) ->
				done null, client.id

			server.deserializeClient (id, done) ->
				db.clients.find id, (err, client) ->
					return done(err) if err
					done null, client
		
			# Register supported grant types.
			#
			# OAuth 2.0 specifies a framework that allows users to grant client applications limited access to their protected resources. It does this through a process of the user granting access, and the client exchanging the grant for an access token.

			# Grant authorization codes. The callback takes the `client` requesting authorization, the `redirectURI` (which is used as a verifier in the subsequent exchange), the authenticated `user` granting access, and their response, which contains approved scope, duration, etc. as parsed by the application. The application issues a code, which is bound to these values, and will be exchanged for an access token.
			server.grant oauth2orize.grant.code((client, redirectURI, user, ares, done) =>
				code = @uid(16)
				db.authorizationCodes.save code, client.id, redirectURI, user.id, (err) ->
					return done(err) if err
					done null, code
			)

			# Exchange authorization codes for access tokens. The callback accepts the `client`, which is exchanging `code` and any `redirectURI` from the authorization request for verification. If these values are validated, the application issues an access token on behalf of the user who authorized the code.
			server.exchange oauth2orize.exchange.code((client, code, redirectURI, done) =>
				db.authorizationCodes.find code, (err, authCode) =>
					return done(err) if err
					return done(null, false) if !authCode?
					return done(null, false) if client.id isnt authCode.clientID
					return done(null, false) if redirectURI isnt authCode.redirectURI
					db.authorizationCodes.delete code, (err) =>
						return done(err) if err
						token = @uid(256)
						db.accessTokens.save token, authCode.userID, authCode.clientID, (err) ->
							return done(err) if err
							done null, token
			)

			# token endpoint
			#
			# `token` middleware handles client requests to exchange authorization grants for access tokens. Based on the grant type being exchanged, the above exchange middleware will be invoked to handle the request. Clients must authenticate when making requests to this endpoint.
			app.post '/odo/auth/oauth2/token', [
				passport.authenticate(
					[
						'basic'
						'oauth2-client-password'
					],
					session: false
				)
				server.token()
				server.errorHandler()
			]
			
			app.get '/odo/auth/oauth2/profile', (req, res) ->
				res.json {
					id: 1
					displayName: 'Thomas Coats'
					username: 'tcoats'
				}
			
			# user authorization endpoint
			#
			# `authorization` middleware accepts a `validate` callback which is responsible for validating the client making the authorization request. In doing so, is recommended that the `redirectURI` be checked against a registered value, although security requirements may vary accross implementations. Once validated, the `done` callback must be invoked with a `client` instance, as well as the `redirectURI` to which the user will be redirected after an authorization decision is obtained.
			#
			# This middleware simply initializes a new authorization transaction. It is the application's responsibility to authenticate the user and render a dialog to obtain their approval (displaying details about the client requesting authorization). We accomplish that here by routing through `ensureLoggedIn()` first, and rendering the `dialog` view. 
			app.get '/odo/auth/oauth2/authorize', [
				login.ensureLoggedIn { redirectTo: config.odo.auth.signin }
				server.authorization (clientID, redirectURI, done) ->
					db.clients.findByClientId clientID, (err, client) ->
						return done err if err

						# WARNING: For security purposes, it is highly advisable to check that redirectURI provided by the client matches one registered with the server. For simplicity, this example does not. You have been warned.
						done null, client, redirectURI
				(req, res, next) ->
					# find client here to auto approve
					#if(!err && client && client.trustedClient && client.trustedClient === true) {
					# # This is how we short call the decision like the dialog below does
					#server.decision({loadTransaction: false}, function(req, callback) {
					#	callback(null, { allow: true });
					#})(req, res, next);
					
					res.redirect "/#auth/oauth2/authorise/#{encodeURIComponent req.query.client_id}/#{req.oauth2.client.name}/#{req.oauth2.transactionID}"
			]
			
			# user decision endpoint
			#
			# `decision` middleware processes a user's decision to allow or deny access requested by a client application. Based on the grant type requested by the client, the above grant middleware configured above will be invoked to send a response.
			app.post '/odo/auth/oauth2/authorize', [
				login.ensureLoggedIn { redirectTo: config.odo.auth.signin }
				server.decision()
			]

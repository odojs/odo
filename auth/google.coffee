define [
	'passport'
	'passport-google'
	'odo/config'
	'odo/auth/provider'
], (passport, passportgoogle, config, ProviderAuthentication) ->
	class GoogleAuthentication extends ProviderAuthentication
		constructor: ->
			@provider = 'google'
			
		web: =>
			passport.use new passportgoogle.Strategy(
				realm: config.passport.google['realm']
				returnURL: config.passport.google['host'] + '/odo/auth/google/callback'
				passReqToCallback: true
			, @signin)
			
			super()

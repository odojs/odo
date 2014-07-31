define [
	'passport'
	'passport-facebook'
	'odo/config'
	'odo/auth/provider'
], (passport, passportfacebook, config, ProviderAuthentication) ->
	class FacebookAuthentication extends ProviderAuthentication
		constructor: ->
			@provider = 'facebook'
			
		web: =>
			passport.use new passportfacebook.Strategy(
				clientID: config.passport.facebook['app id']
				clientSecret: config.passport.facebook['app secret']
				callbackURL: config.passport.facebook['host'] + '/odo/auth/facebook/callback'
				passReqToCallback: true
			, @signin)
			
			super()

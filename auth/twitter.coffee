define [
	'passport'
	'passport-twitter'
	'odo/config'
	'odo/auth/provider'
], (passport, passporttwitter, config, ProviderAuthentication) ->
	class TwitterAuthentication extends ProviderAuthentication
		constructor: ->
			@provider = 'twitter'
			
		web: =>
			passport.use new passporttwitter.Strategy(
				consumerKey: config.passport.twitter['consumer key']
				consumerSecret: config.passport.twitter['consumer secret']
				callbackURL: config.passport.twitter['host'] + '/odo/auth/twitter/callback'
				passReqToCallback: true
			, @signin)
			
			super()

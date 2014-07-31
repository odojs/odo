define [
	'passport'
	'passport-metocean'
	'odo/config'
	'odo/auth/provider'
], (passport, passportmetocean, config, ProviderAuthentication) ->
	class MetOceanAuthentication extends ProviderAuthentication
		constructor: ->
			@provider = 'metocean'
			
		web: =>
			passport.use new passportmetocean.Strategy(
				clientID: config.passport.metocean['client id']
				clientSecret: config.passport.metocean['client secret']
				host: "#{config.metocean.protocol}://#{config.metocean.rootdomain}"
				callbackURL: config.passport.metocean['host'] + 'odo/auth/metocean/callback'
				passReqToCallback: true
			, (req, accessToken, refreshToken, profile, done) =>
				@signin req, accessToken, refreshToken, profile, done)
			
			super()

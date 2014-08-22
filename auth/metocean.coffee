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
			parameters =
				clientID: config.passport.metocean['client id']
				clientSecret: config.passport.metocean['client secret']
				host: "#{config.metocean.protocol}://#{config.metocean.rootdomain}"
				callbackURL: config.passport.metocean['host'] + 'odo/auth/metocean/callback'
				passReqToCallback: true
			
			if config.passport.metocean['directhost']?
				parameters.tokenURL = config.passport.metocean['directhost'] + 'odo/auth/oauth2/token'
				parameters.profileURL = config.passport.metocean['directhost'] + 'odo/auth/oauth2/profile'
				
			passport.use new passportmetocean.Strategy(parameters, (req, accessToken, refreshToken, profile, done) =>
				@signin req, accessToken, refreshToken, profile, done)
			
			super()

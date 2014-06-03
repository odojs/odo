define ['module', 'fs', 'path', 'cson'], (module, fs, path, CSON) ->
	# The configuration structure we are expecting in a config.cson file or as environment variables
	config =
		express:
			'session key': yes
			'cookie secret': yes
			'session secret': yes
			'allowed cross domains': yes
			
		passport:
			twitter:
				'consumer key': yes
				'consumer secret': yes
				host: yes

			facebook:
				'app id': yes
				'app secret': yes
				host: yes

			google:
				realm: yes
				host: yes
			
			metocean:
				'client id': yes
				'client secret': yes
				host: yes
				'authorization url': yes
				'token url': yes

		mandrill:
			'api key': yes
	
	# Recurse through an object looking for equivalent named environment variables
	# e.g if the object is 'passport: google: { realm: yes, host: yes }''
	# Look for: PASSPORT_GOOGLE_REALM and PASSPORT_GOOGLE_HOST variables in the environment and put them in the right place in 'result'
	parse = (prefix, node, result) ->
		for key, value of node
			envkey = "#{prefix}#{key.toUpperCase().replace(/[ -]/g, '_')}"
			
			if typeof value is 'object'
				result[key] = {} if !result[key]?
				parse "#{envkey}_", value, result[key]
				
			else if value is yes and process.env[envkey]?
				result[key] = process.env[envkey]
	
	result = CSON.parseFileSync path.join path.dirname(module.uri), '../../config.cson'
	
	# Look for global configurations
	parse '', config, result
	
	# Also look for application specific overrides
	parse "#{result.odo.domain.toUpperCase().replace(/[ -]/g, '_')}_", config, result
	
	result

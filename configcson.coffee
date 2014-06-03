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
		
		odo:
			auth:
				signout: yes
	
	copy = (source, target) ->
		for key, value of source
			if typeof value is 'object'
				target[key] = {} if !target[key]?
				copy value, target[key]
			else
				target[key] = value
			
	
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
	
	if process.env.ODO_CONFIG?
		odoconfig = CSON.parseSync process.env.ODO_CONFIG
		copy odoconfig, result
	
	envdomain = result.odo.domain.toUpperCase().replace(/[ -]/g, '_')
	
	if process.env["#{envdomain}_ODO_CONFIG"]?
		domainodoconfig = CSON.parseSync process.env["#{envdomain}_ODO_CONFIG"]
		copy domainodoconfig, result
	
	# Look for global configurations
	parse '', config, result
	
	# Also look for application specific overrides
	parse "#{envdomain}_", config, result
	
	result

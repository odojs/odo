define ['module', 'fs', 'path', 'cson'], (module, fs, path, CSON) ->
	# The configuration structure we are expecting in a config.cson file or as environment variables
	# The structure is turned into variables like 'EXPRESS_SESSION_KEY', and the domain specific override is also checked 'ODO_EXAMPLE_EXPRESS_SESSION_KEY'
	template =
		express:
			'session key': yes
			'cookie secret': yes
			'session secret': yes
			'allowed cross domains': yes
			'port': yes
			
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
				metocean:
					successRedirect: yes
					failureRedirect: yes
	
	# Copy all of the properties on source to target, recurse if an object
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
		result = {} if !result?
		
		for key, value of node
			envkey = "#{prefix}#{key.toUpperCase().replace(/[ -]/g, '_')}"
			
			if typeof value is 'object'
				result[key] = {} if !result[key]?
				parse "#{envkey}_", value, result[key]
				
			else if value is yes and process.env[envkey]?
				console.log "Reading #{envkey}"
				result[key] = process.env[envkey]
		
		result
	
	localfile = CSON.parseFileSync path.join path.dirname(module.uri), '../../config.cson'
	
	envdomain = localfile.odo.domain.toUpperCase().replace(/[ -]/g, '_')
	
	# Look for the global configuration blob
	globalenvvar = 'ODO_CONFIG'
	globalenvblob = {}
	if process.env[globalenvvar]?
		#console.log "Reading #{globalenvvar}"
		globalenvblob = CSON.parseSync process.env[globalenvvar]
	
	# Look for global configurations
	globalenv = parse '', template
	
	# Look for the domain specific configuration blob
	domainenvvar = "#{envdomain}_ODO_CONFIG"
	domainenvblob = {}
	if process.env[domainenvvar]?
		#console.log "Reading #{domainenvvar}"
		domainenvblob = CSON.parseSync process.env[domainenvvar]
	
	# Also look for domain specific overrides
	domainenv = parse "#{envdomain}_", template
	
	# Merge down the configuration objects in order
	result = localfile
	copy object, result for object in [
		globalenvblob
		globalenv
		domainenvblob
		domainenv
	]
	result

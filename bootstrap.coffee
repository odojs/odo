define ['odo/plugins', 'odo/config'], (Plugins, config) ->
	(contexts) ->
		config.contexts = contexts
		
		requirejs config.systems, (plugins...) ->
			plugins = new Plugins plugins
			
			contexts = [contexts] if typeof contexts is 'string'
			
			for context in contexts
				plugins.run context
			
			requirejs ['odo/hub'], (hub) ->
				for context in contexts
					continue if !config[context]?
					for e in config[context]
						hub.publish event: e.e, payload: e.p if e.e?
						hub.send command: e.c, payload: e.p if e.c?

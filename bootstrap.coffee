define [
	'odo/plugins'
	'odo/hub'
	'odo/config'
], (Plugins, hub, config) ->
	(contexts) ->
		requirejs config.systems, (plugins...) ->
			plugins = new Plugins plugins
			
			contexts = ['web'] if !contexts?
			contexts = [contexts] if typeof contexts is 'string'
			contexts = ['web'] if contexts.length is 0
			
			for context in contexts
				plugins[context]()
			
			for context in contexts
				continue if !config[context]?
				for e in config[context]
					hub.publish event: e.e, payload: e.p if e.e?
					hub.send command: e.c, payload: e.p if e.c?

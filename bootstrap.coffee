define [
	'odo/plugins'
	'odo/messaging/hub'
	'odo/config'
], (Plugins, hub, config) ->
	requirejs config.systems, (plugins...) ->
		plugins = new Plugins plugins
		contexts = process.argv.slice 2
		
		for context in contexts
			plugins[context]()
		
		for context in contexts
			continue if !config[context]?
			for e in config[context]
				hub.publish event: e.e, payload: e.p if e.e?
				hub.send command: e.c, payload: e.p if e.c?

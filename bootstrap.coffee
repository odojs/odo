define [
	'domain'
	'odo/plugins'
	'odo/config'
	'odo/async'
], (domain, Plugins, config, async) ->
	(contexts) ->
		d = domain.create();
		d.on 'error', (err) ->
			console.error err
			process.exit 1

		d.run ->
			config.contexts = contexts
			
			requirejs config.systems, (plugins...) ->
				plugins = new Plugins plugins
				
				contexts = [contexts] if typeof contexts is 'string'
				plugins.run context for context in contexts
				
				requirejs ['odo/hub'], (hub) ->
					tasks = []
					for context in contexts
						continue if !config[context]?
						for item in config[context]
							for event, payload of item
								do (event, payload) ->
									tasks.push (tcb) ->
										hub.ready (rcb) ->
											rcb()
											hub.emit event, payload, ->
												tcb()
					
					if tasks.length > 0
						async.series tasks, ->
							console.log 'Finished playback of events'

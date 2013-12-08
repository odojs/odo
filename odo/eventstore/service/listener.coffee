define ['service/hub', 'service/itemlistener'], (hub, itemlistener) ->
	start: ->
		bindings = {}
		addBinding = (binding) ->
			for name, method of binding
				if !bindings[name]?
					bindings[name] = []
				bindings[name].push method
		addBinding itemlistener
		
		hub.on 'events', (data) ->
			console.log data
			console.log "eventDenormalizer -- denormalize event #{data.event}"
			if bindings[data.event]?
				for listener in bindings[data.event]
					listener data
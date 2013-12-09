define ['odo/hub', 'odo/injectinto'], (hub, inject) ->
	start: ->
		hub.on 'events', (data) ->
			console.log data
			console.log "eventDenormalizer -- denormalize event #{data.event}"
			
			for listener in inject.many "eventlisteners:#{data.event}"
				listener data
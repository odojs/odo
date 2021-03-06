define [
	'odo/template'
	'odo/async'
	'odo/sequencer'
	'odo/colours'
], (template, async, Sequencer) ->
	# Simple publish and subscribe
	# Publish is async
	class Hub
		constructor: ->
			@listeners = {}
			@sequencer = new Sequencer()
		
		_every: (e, cb) =>
			@listeners[e] = [] if !@listeners[e]?
			@listeners[e].push cb
			
			off: =>
				index = @listeners[e].indexOf(cb)
				if index isnt -1
					@listeners[e].splice index, 1
		
		# Subscribe to an event
		every: (events, cb) =>
			events = [events] unless events instanceof Array
			bindings = for e in events
				event: e
			
			for e in bindings
				e.binding = @_every e.event, cb
			
			off: => e.binding.off() for e in bindings
		
		_once: (e, cb) =>
			binding = @every e, (payload, callback) =>
				binding.off()
				cb payload, callback
			off: -> binding.off()
		
		once: (events, cb) =>
			events = [events] unless events instanceof Array
			
			count = 0
			bindings = for e in events
				count++
				event: e
				complete: no
			
			for e in bindings
				e.binding = @_once e.event, (m, callback) ->
					count--
					e.complete = yes
					if count is 0
						cb(m, callback)
					else
						callback()
			
			off: -> e.binding.off() for e in bindings
		
		any: (events, cb) =>
			bindings = for e in events
				event: e
			
			unbind = -> e.binding.off() for e in bindings
			
			for e in bindings
				e.binding = @_once e.event, ->
					unbind()
					cb()
			
			off: unbind
		
		# Publish an event
		emit: (e, m, ecb) =>
			description = "#{template e, m}"
			console.log " #{'*'.blue} #{description}"
			
			tasks = []
			if @listeners[e]?
				for listener in @listeners[e].slice()
					do (listener) =>
						tasks.push (pcb) =>
							@sequencer.exec description, (scb) ->
								listener m, ->
									pcb()
									scb()
			
			async.parallel tasks, -> ecb() if ecb?
		
		ready: (cb) =>
			@sequencer.ready cb
	
	new Hub()

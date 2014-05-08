define [], ->
	class Sequencer
		constructor: ->
			@_queue = []
			@_inprogress = no
			@_last = null
			
			setInterval(=>
				if @_inprogress
					console.log "Waiting for"
					console.log @_last
			, 1000)
			
		_next: =>
			@_inprogress = yes
			
			# if we've finished the queue we are done
			if @_queue.length is 0
				@_inprogress = no
				return
			
			# pull off the next item and give it a callback
			item = @_queue.shift()
			@_last = item.event
			item.action @_next
		
		push: (event, action) =>
			# add another item to the queue
			@_queue.push
				event: event
				action: action
			
			# if we aren't running, start running
			if !@_inprogress
				@_next()

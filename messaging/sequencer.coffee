define [], ->
	class Sequencer
		constructor: ->
			@_queue = []
			@_inprogress = no
			
		_next: =>
			@_inprogress = yes
			
			# if we've finished the queue we are done
			if @_queue.length is 0
				@_inprogress = no
				return
			
			# pull off the next item and give it a callback
			action = @_queue.shift()
			action @_next
		
		push: (action) =>
			# add another item to the queue
			@_queue.push action
			
			# if we aren't running, start running
			if !@_inprogress
				@_next()
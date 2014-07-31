define ['odo/colours'], ->
	class Sequencer
		constructor: ->
			@_queue = []
			@_inprogress = no
			@_timeout = 1000
			@_ready = []

		_next: =>
			@_inprogress = yes
			clearInterval @_interval if @_interval?
			
			# if we've finished the queue we are done
			if @_queue.length is 0
				return @_inprogress = no if @_ready.length is 0
				@_queue.push
					description: 'ready'
					action: @_ready.shift()
			
			# pull off the next item and give it a callback
			item = @_queue.shift()
			duration = 0
			@_interval = setInterval =>
				duration += @_timeout
				console.log " #{'?'.red} #{item.description.green} has been running for #{"#{duration / 1000} seconds".blue}"
			, @_timeout
			
			item.action =>
				item.callback() if item.callback?
				@_next()
		
		exec: (description, action, cb) =>
			# add another item to the queue
			@_queue.push
				description: description
				action: action
				callback: cb
			
			# if we aren't running, start running
			@_next() if !@_inprogress
		
		ready: (callback) =>
			return callback(->) if !@_inprogress
			@_ready.push callback

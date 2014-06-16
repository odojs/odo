define [], ->
	class Recorder
		constructor: (methods) ->
			@_calls = []
			if methods?
				for method in methods
					@[method] = @_record method
		
		_record: (method) =>
			=>
				@_calls.push
					method: method
					params: arguments
		
		play: (target, methods) =>
			if !methods?
				for call in @_calls
					target[call.method].apply target, call.params
				return
			
			for call in @_calls
				if methods.indexOf(call.method) isnt -1
					target[call.method].apply target, call.params

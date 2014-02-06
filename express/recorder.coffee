define [], ->
	class Recorder
		constructor: (methods) ->
			@_calls = []
			for method in methods
				@[method] = @_record method
		
		_record: (method) =>
			=>
				@_calls.push
					method: method
					params: arguments
		
		play: (target) =>
			for call in @_calls
				target[call.method].apply target, call.params
define [], ->
	class Recorder
		_calls: []
		
		constructor: (methods) ->
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
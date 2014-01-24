define [], ->
	class Recorder
		_calls: []
		
		_record: (method) =>
			() =>
				@_calls.push
					method: method
					params: Array::slice.call arguments, 0
		
		constructor: (methods) ->
			for method in methods
				@[method] = @_record method
		
		play: (target) =>
			for call in @_calls
				target[call.method].apply target, call.params
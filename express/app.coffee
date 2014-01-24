define ['odo/infra/recorder'], (Recorder) ->	
	class Init extends Recorder
		constructor: ->
			super
	
	new Init [
		'get'
		'post'
		'put'
		'delete'
	]
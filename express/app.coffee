define ['odo/express/recorder'], (Recorder) ->	
	class Init extends Recorder
		constructor: ->
			super
	
	new Init [
		'get'
		'post'
		'put'
		'delete'
	]
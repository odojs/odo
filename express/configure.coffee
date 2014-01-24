define ['odo/infra/recorder'], (Recorder) ->	
	class Configure extends Recorder
		constructor: ->
			super
		
		modulepath: (uri) ->
			items = uri.split '/'
			items.pop()
			items.join '/'
	
	new Configure [
		'route'
	]
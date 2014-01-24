define [], () ->	
	# not sure why I can't use the Recorder here, but... I can't
	
	_uses = []
	
	use: (use) ->
		_uses.push use
	
	play: (app) ->
		for use in _uses
			app.use use
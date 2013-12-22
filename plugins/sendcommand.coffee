define ['odo/hub'], (hub) ->
	
	init: (app) ->
		app.post '/sendcommand/:command', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			req.body.by = req.user.id
			
			hub.send
				command: req.params.command
				payload: req.body
			
			res.send 'Ok'
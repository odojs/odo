define ['odo/express'], (express) ->
	components = []
	
	web: ->
		express.get '/odo/components', (req, res) -> res.send components
		
	register: (component) ->
		components.push component

define ['module'], (module) ->
	components = []
	
	configure: (app) ->
		app.route '/odo/durandal', app.modulepath(module.uri) + '/public'
		
		app.durandal = (component) ->
			components.push component
		
	init: (app) ->
		app.get '/odo/components', (req, res) ->
			res.send components
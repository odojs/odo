define ['module', 'odo/express'], (module, express) ->
	
	components = []
	
	web: ->
		express.route '/odo/durandal', express.modulepath(module.uri) + '/public'
		
		express.get '/odo/components', (req, res) ->
			res.send components
		
	register: (component) ->
		components.push component

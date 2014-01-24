define ['module', 'odo/express/configure', 'odo/express/app'], (module, configure, app) ->
	
	components = []
	
	web: ->
		configure.route '/odo/durandal', configure.modulepath(module.uri) + '/public'
		
		app.get '/odo/components', (req, res) ->
			res.send components
		
	register: (component) ->
		components.push component
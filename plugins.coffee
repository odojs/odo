define [], () ->
	class Plugins
		constructor: (plugins) ->
			@plugins = plugins
			@plugins = @plugins.map (plugin) ->
				if typeof(plugin) is 'function'
					return new plugin
				plugin
		
		web: =>
			for plugin in @plugins
				if plugin.web?
					plugin.web()
		
		domain: =>
			for plugin in @plugins
				if plugin.domain?
					plugin.domain()
		
		projection: =>
			for plugin in @plugins
				if plugin.projection?
					plugin.projection()

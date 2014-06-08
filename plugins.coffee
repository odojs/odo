define [], () ->
	class Plugins
		contexts: [
			'web'
			'domain'
			'projection'
			'api'
		]
		
		constructor: (plugins) ->
			@plugins = plugins
			@plugins = @plugins.map (plugin) ->
				return new plugin if typeof(plugin) is 'function'
				plugin
			
			@[context] = @context context for context in @contexts
		
		context: (name) => =>
			for plugin in @plugins
				plugin[name]() if plugin[name]?

define [], () ->
	class Plugins
		contexts: [
			'web'
			'domain'
			'projection'
			'api'
			'build'
			'cmd'
		]
		
		constructor: (plugins) ->
			@plugins = plugins
			@plugins = @plugins.map (plugin) ->
				return new plugin if typeof(plugin) is 'function'
				plugin
			
			@[context] = @context context for context in @contexts
		
		run: (name) =>
			plugin[name]() for plugin in @plugins.filter (p) -> p[name]?
		
		context: (name) => => @run name

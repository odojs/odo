define [
	'module'
	'handlebars'
	'express/lib/response'
	'consolidate'
	'underscore'
	'path'
	'odo/express/app']
, (module, handlebars, response, cons, _, path, app) ->
	class Handlebars
		web: =>
			#res.render
			#	view: 'odo/layout'
			#	data:
			#		title: 'Display'
			#		user: req.user
			#		bodyclasses: [
			#			'lead'
			#		]
			#	partials:
			#		content: 'plugins/display/display'
			#	result: (err, str) ->
			#		console.log str
			#		res.send str

			# Replace existing render with new version that adds more variables
			# and copies partials
			response.render = (options) ->
				self = @
				req = @req
				app = req.app

				view = options.view
				if options.result?
					result = options.result

				options = _.extend {}, options.data, self.locals, {
					query: req.query
					body: req.body
					partials: _.extend {}, self.locals.partials, options.partials
				}

				# Merge res.locals
				options._locals = self.locals

				# Default callback to respond
				fn = result or (err, str) ->
					return req.next(err) if err
					self.send str

				# Render
				app.render view, options, fn

			app.engine('html', cons.handlebars)
			app.set('view engine', 'html')
			app.set('views', path.dirname(module.uri) + '/../../../')
			
			# 'hello' -> 'HELLO'
			handlebars.registerHelper 'uppercase', (string) ->
				string.toUpperCase()

			# 'Hello' -> 'hello'
			handlebars.registerHelper 'lowercase', (string) ->
				string.toLowerCase()

			# 'hello my name is' -> 'Hello My Name Is'
			if String::toTitleCase?
				handlebars.registerHelper 'titlecase', (string) ->
					string.toTitleCase()

			# Support rendering the string value in a variable
			# adjective = 'great'
			# item = 'this is a {{adjecive}} template'
			# {{render item}}
			# = this is a great template
			handlebars.registerHelper 'render', (content, options) ->
				if content?
					return new handlebars.SafeString handlebars.compile(content)(@)
				''

			# Provide an extension point that anyone can attach content to
			# Will look for partials first, then variables
			# Variables will be rendered as templates
			handlebars.registerHelper 'hook', (partial, options) ->
				if !@.partials[partial]?
					return new handlebars.SafeString handlebars.compile('{{render ' + partial + '}}')(@)
				
				new handlebars.SafeString handlebars.compile('{{> ' + partial + '}}')(@)

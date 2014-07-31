define [
	'module'
	'path'
	'handlebars'
	'consolidate'
	'express/lib/response'
	'odo/express'
], (module, path, handlebars, cons, response, express) ->
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

				content = {}
				
				content[key] = value for key, value of options.data
				content[key] = value for key, value of self.locals
				content.query = req.query
				content.body = req.body
				content.partials = {}
				content.partials[key] = value for key, value of self.locals.partials
				content.partials[key] = value for key, value of options.partials

				# Merge res.locals
				content._locals = self.locals

				# Default callback to respond
				fn = result or (err, str) ->
					return req.next(err) if err
					self.send str

				# Render
				app.render view, content, fn

			express.engine 'html', cons.handlebars
			express.set 'view engine', 'html'
			express.set('views', path.dirname(module.uri) + '/../../')
			
			# 'hello' -> 'HELLO'
			handlebars.registerHelper 'uppercase', (string) -> string.toUpperCase()

			# 'Hello' -> 'hello'
			handlebars.registerHelper 'lowercase', (string) -> string.toLowerCase()

			# 'hello my name is' -> 'Hello My Name Is'
			if String::toTitleCase?
				handlebars.registerHelper 'titlecase', (string) -> string.toTitleCase()

			# Support rendering the string value in a variable
			# adjective = 'great'
			# item = 'this is a {{adjecive}} template'
			# {{render item}}
			# = this is a great template
			handlebars.registerHelper 'render', (content, options) ->
				return '' if !content?
				new handlebars.SafeString handlebars.compile(content)(@)

			# Provide an extension point that anyone can attach content to
			# Will look for partials first, then variables
			# Variables will be rendered as templates
			handlebars.registerHelper 'hook', (partial, options) ->
				return new handlebars.SafeString handlebars.compile('{{render ' + partial + '}}')(@) if !@.partials[partial]?
				new handlebars.SafeString handlebars.compile('{{> ' + partial + '}}')(@)

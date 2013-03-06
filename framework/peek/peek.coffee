express = require 'express'
expressutils = require 'express/lib/utils'
parse = require('url').parse
parseUrl = (req) ->
	parsed = req._parsedUrl
	if parsed and parsed.href == req.url
		parsed
	else
		req._parsedUrl = parse req.url

# let components peak requests instead of being responsible for them
# so a component can snoop and modify variables
# app.peek.get '/user/:id', (req, res) ->

module.exports =
	configure: (app) ->
		peeks = []
		register = (method, path, callback) ->
			peek = {
				path: path
				method: method
				callback: callback
				keys: []
			}
			peek.regexp = expressutils.pathRegexp peek.path, peek.keys, false, false
			peeks.push peek

		app.peek = {}

		for method in ['get', 'post', 'put', 'delete']
			do (method) ->
				app.peek[method] = (path, callback) ->
					register method, path, callback

		app.use (req, res, next) ->
			method = req.method.toLowerCase()
			url = parseUrl req
			path = url.pathname

			for peek in peeks
				req.params = []
				m = peek.regexp.exec path

				continue unless m

				continue unless peek.method is req.method.toLowerCase()

				i = 1
				len = m.length

				while i < len
					key = peek.keys[i - 1]

					val = (if "string" is typeof m[i] then decodeURIComponent m[i] else m[i])
					if key
						req.params[key.name] = val
					else
						req.params.push val
					++i

				peek.callback req, res
			next()
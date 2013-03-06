_ = require 'underscore'

module.exports =
	init: (app) ->
		load = (req, res) ->
			res.locals.partials = {
				password: 'example-password/password'
			}

		app.peek.get '/login-example', load

		app.peek.post '/login-example', (req, res) ->
			console.log 'Password: ' + req.body.password
			load req, res
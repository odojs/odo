_ = require 'underscore'

module.exports =
	init: (app) ->
		load = (req, res) ->
			res.render 'layout', {
				title: 'Test',
				partials: {
					content: 'example/test'
				}
			}

		app.get '/login-example', load

		app.post '/login-example', (req, res) ->
			console.log 'Username: ' + req.body.username

			load req, res
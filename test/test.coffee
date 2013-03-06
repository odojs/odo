express = require 'express'

module.exports =
	init: (app) ->
		app.get '/test', (req, res) ->
			res.send 'Hi'
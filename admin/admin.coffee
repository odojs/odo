express = require 'express'

module.exports =
	configure: (app) ->
		app.use('/js', express.static(__dirname + '/js'))
		app.use('/css', express.static(__dirname + '/css'))
		app.use('/img', express.static(__dirname + '/img'))
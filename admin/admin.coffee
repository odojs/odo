express = require 'express'

components = [
	require './dashboard'
]

module.exports =
	configure: (app) ->
		app.use('/js', express.static(__dirname + '/js'))
		app.use('/css', express.static(__dirname + '/css'))
		app.use('/img', express.static(__dirname + '/img'))
		for component in components
			component.configure app if component.configure?

	init: (app) ->
		for component in components
			component.init app if component.init?
	

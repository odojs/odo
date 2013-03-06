express = require 'express'
_ = require 'underscore'

module.exports =
	configure: (app) ->
		app.use('/css', express.static(__dirname + '/css'))
		app.use('/img', express.static(__dirname + '/img'))
		app.use('/js', express.static(__dirname + '/js'))

	init: (app) ->
		app.get '/%CF%86/incoming/', (req, res) ->
			console.log req.session.test

			res.render
				view: 'odo/layout'
				data:
					title: 'Incoming'
					javascripts: [
						'/js/incoming.js'
					]
					bodyclasses: [
						'prompt'
					]
				partials:
					content: 'incoming/incoming'
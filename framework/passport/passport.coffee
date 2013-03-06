express = require 'express'
passport = require 'passport'

module.exports =
	configure: (app) ->
		app.use passport.initialize()
		app.use passport.session()

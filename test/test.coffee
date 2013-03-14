express = require 'express'

module.exports =
  init: (app) ->

    app.peek.get '/test**', (req, res, next) ->
      res.locals.user =
        name: 'Thomas Coats'
        title: 'Master'
      next()

    app.peek.get '/test**', (req, res, next) ->
      res.render
        view: 'test/display'
        data:
          name: 'Thomas'
        result: (error, html) ->
          throw error if error?
          res.locals.content = html
          next()

    app.peek.get '/test**', (req, res, next) ->
      res.locals.partials.menu = 'menu'
      next()


    app.get '/test', (req, res) ->
      res.render
        view: 'test/layout'
        data:
          title: 'Display'
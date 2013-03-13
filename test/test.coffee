express = require 'express'

module.exports =
  init: (app) ->
    app.peek.get '/test', (req, res, next) ->
      await res.render
        view: 'test/display'
        data:
          name: 'Thomas'
        result: defer error, html

      res.locals.content = html

      next()

    app.get '/test', (req, res) ->
      res.render
        view: 'test/layout'
        data:
          title: 'Display'
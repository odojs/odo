express = require 'express'
_ = require 'underscore'



module.exports =
  configure: (app) ->
    app.use('/img', express.static(__dirname + '/img'))

  init: (app) ->
    app.get '/', (req, res) ->
      res.render
        view: 'odo/layout'
        data:
          title: 'Display'
          user: req.user
          bodyclasses: [
            'lead'
          ]
        partials:
          content: 'display/display'
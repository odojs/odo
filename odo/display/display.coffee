express = require 'express'
_ = require 'underscore'



module.exports =
  configure: (app) ->
    app.use('/js/odo/display', express.static(__dirname + '/js'))

  init: (app) ->
    app.get '/', (req, res) ->
      await app.fetch.exec 'pagetitles', 'all', app, null, defer error, sections
      
      res.render
        view: 'odo/layout'
        data:
          title: 'Display'
          user: req.user
          sections: sections
          javascripts: [
            '/js/odo/display/display.js'
          ]
        partials:
          content: 'display/display'
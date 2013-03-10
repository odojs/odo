express = require 'express'
_ = require 'underscore'



module.exports =
  configure: (app) ->
    #app.use('/img', express.static(__dirname + '/img'))

  init: (app) ->
    app.get '/', (req, res) ->
      await app.fetch.exec 'pagetitles', 'all', app, null, defer error, sections
      
      res.render
        view: 'odo/layout'
        data:
          title: 'Display'
          user: req.user
          sections: sections
        partials:
          content: 'display/display'
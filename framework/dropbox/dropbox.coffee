dropbox = require 'dropbox'

module.exports =
  configure: (app) ->
  	app.inject.bind 'dropbox.client', () ->
      req = app.inject.one 'req'

      if !req.user?
        return null

      new dropbox.Client {
        key: app.get 'dropbox key'
        secret: app.get 'dropbox secret'
        token: req.user.token
        tokenSecret: req.user.tokenSecret
        uid: req.user._json.uid
      }
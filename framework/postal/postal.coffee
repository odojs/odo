postal = require 'postal'

module.exports =
  configure: (app) ->
    app.postal = postal()
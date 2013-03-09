# # Fetching Strategy

_ = require 'underscore'

class Fetch
  constructor: () ->
    @strategies = {}

  # Register a way to get fetch using a specification spec
  # E.g. fetch = 'Last Purchased Product' spec = 'ByUser'
  bind: (fetch, spec, implementation) ->
    @strategies[fetch] = {} if !@strategies[fetch]?
    if @strategies[fetch][spec]?
      throw new Error "Existing implementation for #{fetch}->#{spec}"
    @strategies[fetch][spec] = implementation

  getAll: () ->
    @strategies

module.exports =
  configure: (app) ->
    app.fetch = new Fetch

  init: (app) ->
    # Expose fetching strategies as json
    for fetch, specs of app.fetch.getAll()
      for spec, implementation of specs
        do (app, fetch, spec, implementation) ->
          app.get "/fetch/#{fetch}/#{spec}", (req, res) ->
            implementation app, req.query, (error, result) ->
              throw error if error?
              res.send result
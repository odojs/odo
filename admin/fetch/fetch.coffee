_ = require 'underscore'

module.exports =
  init: (app) ->
    # Show available strategies
    app.get "/%CF%88/fetch/", (req, res) ->
      res.locals.strategies = for fetch, specifications of app.fetch.getAll()
        name: fetch
        specifications: for spec, implementation of specifications
          name: spec

      res.render
        view: 'admin/layout'
        data:
          title: 'Ψ -> Fetching strategies'
          bodyclasses: ['prompt']
        partials:
          content: 'fetch/fetch'

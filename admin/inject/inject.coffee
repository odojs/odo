_ = require 'underscore'

whatisit = (thing) ->
  tests =
    array: _.isArray
    arguments: _.isArguments
    function: _.isFunction
    string: _.isString
    number: _.isNumber
    boolean: _.isBoolead
    date: _.isDate
    regex: _.isRegEx
    null: _.isNull
    undefined: _.isUndefined

  if _.isObject thing
    return thing.constructor.name

  for key, test of tests
    return key if test thing

  'unknown'

module.exports =
  init: (app) ->
    # Show available bindings
    app.get "/%CF%88/inject/", (req, res) ->
      res.locals.bindings = for key, items of app.inject.bindings
        key: key
        count: items.length

      res.render
        view: 'admin/layout'
        data:
          title: 'Ψ -> Fetching strategies'
          bodyclasses: ['prompt']
        partials:
          content: 'inject/inject'

    app.get "/%CF%88/inject/:key", (req, res) ->
      res.locals.binding =
        key: req.params.key

      res.locals.binding.values = app.inject.bindings[req.params.key].map (binding) ->
          result =
            type: whatisit binding

          result.keys = _(binding).keys() if _.isObject binding
          result.keys = binding.params() if _.isFunction binding
          result.keys = binding.params() if result.type is 'Function'

          result

      res.render
        view: 'admin/layout'
        data:
          title: "Ψ -> Fetching strategies -> #{req.params.key}"
          bodyclasses: ['prompt']
        partials:
          content: 'inject/binding'

dropbox = require 'dropbox'

errors = {
  '${dropbox.ApiError.INVALID_TOKEN}': 'Invalid token'
  '${dropbox.ApiError.NOT_FOUND}': 'Not found'
  '${dropbox.ApiError.OVER_QUOTA}': 'Over quota'
  '${dropbox.ApiError.RATE_LIMITED}': 'Rate limited'
  '${dropbox.ApiError.NETWORK_ERROR}': 'Network error'
  '${dropbox.ApiError.INVALID_PARAM}': 'Invalid parameter'
  '${dropbox.ApiError.OAUTH_ERROR}': 'OAuth Error'
  '${dropbox.ApiError.INVALID_METHOD}': 'Invalid method'
}

strategies = (app) ->
  'dropbox.collections': (callback) ->
    callback null, [
      'Knowledge/Patterns and Practices'
      'Knowledge/Work'
      'Knowledge/Brain Dump'
      'Knowledge/Leader of Men'
    ]

  'dropbox.list': (callback) ->
    req = app.inject.one 'req'
    client = app.inject.one('dropbox.client')()

    if !client?
      callback null, []
      return

    await client.readdir req.query.path, defer error, entries
    
    if error?
      callback errors[error]

    callback null, entries


# Export the strategy to inject and json
module.exports =
  configure: (app) ->
    for strategy, implementation of strategies app
      app.inject.bind strategy, implementation

  init: (app) ->
    for strategy, _ of strategies app
      app.get "/#{strategy}.json", (req, res) ->
        await app.inject.one(strategy) (defer error, result)
        
        throw error if error?
        output = JSON.stringify result
        res.set
          'Content-Type': 'application/json'
          'Content-Length': output.length
        res.send output
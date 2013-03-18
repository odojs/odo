path = require 'path'
fs = require 'fs'
express = require 'express'
inject = require 'injectinto'
peek = require 'peekinto'
postal = require 'postal'
fetching = require 'fetching'
app = express()

# Configuration
configpath = path.join __dirname, 'config.json'
await fs.readFile configpath, defer err, configfile
config = JSON.parse configfile, 'utf-8'

# Plugins
app.plugins = require './plugins'
await app.plugins.loadplugins config.plugins.directories, defer()

for key, value of config.config
  app.set key, value

# Configure express
app.configure () =>
  # Use default middleware
  #app.use express.logger()
  app.use express.compress()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser app.get 'cookie secret'
  app.use express.cookieSession
    key: app.get 'session key'
    secret: app.get 'session secret'

  # Create configured routes
  for route in config.routes
    app.use(route.source, express.static(__dirname + route.target))

  # Dependency injection
  app.inject = new inject
  app.use (req, res, next) ->
      app.inject.clear 'req'
      app.inject.bind 'req', req
      app.inject.clear 'res'
      app.inject.bind 'res', res
      next()

  # Publish subscribe
  app.postal = postal()    
  
  # Peek into a request, perform processing but not be responsible for the output.
  peek app
  
  # Fetching strategies
  app.fetch = new fetching

  # Configure plugins
  await app.plugins.configure app, defer()
  
  app.use app.router

  # Error handling
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.listen(process.env.PORT || 80)

# Fetching strategies middleware
app.fetch.middleware app

# Initialise plugins
await app.plugins.init app, defer()
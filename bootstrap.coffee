path = require 'path'
fs = require 'fs'
express = require 'express'
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

  # Configure plugins
  await app.plugins.configure app, defer()
  
  app.use app.router

  # Error handling
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.listen(process.env.PORT || 80)

# Initialise plugins
await app.plugins.init app, defer()
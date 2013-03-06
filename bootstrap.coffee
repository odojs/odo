path = require 'path'
express = require 'express'
fs = require 'fs'
app = express()
config = config = JSON.parse fs.readFileSync (path.join __dirname, 'config.json'), 'utf-8'

app.plugins = require './plugins'

# plugins
app.plugins.loadplugins config.plugins.directories

for key, value of config.config
  app.set key, value

# configure
app.configure () =>
  # default middleware
  #app.use express.logger()
  app.use express.compress()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser app.get 'cookie secret'
  app.use express.cookieSession
    key: app.get 'session key'
    secret: app.get 'session secret'

  for source, target of config.routes
    app.use(source, express.static(__dirname + target))

  # plugin middleware
  app.plugins.configure app
  
  app.use app.router

  # error handling
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

# init
app.plugins.init app

app.listen(process.env.PORT || 80)
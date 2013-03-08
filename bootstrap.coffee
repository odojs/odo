path = require 'path'
express = require 'express'
fs = require 'fs'
app = express()


configpath = path.join __dirname, 'config.json'
await fs.readFile configpath, defer err, configfile
config = JSON.parse configfile, 'utf-8'

app.plugins = require './plugins'

# plugins
await app.plugins.loadplugins config.plugins.directories, defer()

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
  await app.plugins.configure app, defer()
  
  app.use app.router

  # error handling
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.listen(process.env.PORT || 80)

# init
await app.plugins.init app, defer()
express = require 'express'
path = require 'path'
less = require './less'
nun = require './nun'
static = require './static'
route = require './route'
view = require './view'
app = require './app'

# general configuration
require './underscore'
app.configure () =>
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
        
# user content
app.configure () =>
    app.set 'content', path.normalize(__dirname + '/../content/')
    app.use route '/content/', app.set('content'), static()

# normal www directory
app.configure () =>
    app.set 'www', path.normalize(__dirname + '/../www/')
    app.use view
        search: [ app.set 'www' ]
    app.use app.router
    app.use route '/', app.set('www'), less()
    app.use route '/', app.set('www'), nun()
    app.use route '/', app.set('www'), static()

# wiki
require '../services/wiki'
app.configure () =>
    app.set 'wiki', path.normalize(__dirname + '/../../BrainDump/wiki/')
    app.use route '/wiki/braindump.md.txt', path.normalize(__dirname + '/../../BrainDump/README.md'), static()
    app.use route '/wiki/lightweight.md.txt', path.normalize(__dirname + '/../README.md'), static()
    app.use route '/wiki/', app.set('wiki'), static()

# examples
require '../examples/list'
require '../examples/store'
require '../examples/upload'
require '../examples/template'
require '../examples/worker'
app.configure () =>
    app.set 'examples', path.normalize(__dirname + '/../examples-www/')
    app.use route '/', app.set('examples'), less()
    app.use route '/', app.set('examples'), nun()
    app.use route '/', app.set('examples'), static()

# if nothing was matched show the error handler
app.configure () =>
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
express = require 'express'
path = require 'path'
less = require './less'
nun = require './nun'
static = require './static'
route = require './route'
view = require './view'
app = require './app'

app.configure () =>
    app.set 'www', path.normalize(__dirname + '/../www/')
    app.set 'upload', path.normalize(__dirname + '/../upload/')
    app.set 'wiki', path.normalize(__dirname + '/../../BrainDump/wiki/')
    
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
    app.use view
        search: [ path.normalize(__dirname + '/../www/') ]
    app.use app.router
    app.use route '/', app.set('www'), less()
    app.use route '/', app.set('www'), nun()
    app.use route '/wiki/', app.set('wiki'), static()
    app.use route '/', app.set('www'), static()
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
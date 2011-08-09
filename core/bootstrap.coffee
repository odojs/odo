express = require 'express'
path = require 'path'
less = require './less'
sass = require './sass'
nun = require './nun'
static = require './static'
route = require './route'
view = require './view'
app = require './app'

root = path.normalize(__dirname + '/../')

# general configuration
require './underscore'
app.configure () =>
    app.set 'root', root
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
        
# user content
app.configure () =>
    app.set 'content', (root + 'content/')
    app.use route '/content/', app.set('content'), static()

# normal www directory
app.configure () =>
    app.set 'www', (root + 'www/')
    app.use view
        search: [ app.set 'www' ]
    app.use app.router
    app.use route '/', app.set('www'), less()
    app.use route '/', app.set('www'), sass()
    app.use route '/', app.set('www'), nun()
    app.use route '/', app.set('www'), static()

# wiki
require '../services/wiki'
app.configure () =>
    app.set 'wiki', path.normalize(root + '../BrainDump/wiki/')
    app.use route '/wiki/braindump.md.txt', path.normalize(root + '../BrainDump/README.md'), static()
    app.use route '/wiki/lightweight.md.txt', (app.set('root') + 'README.md'), static()
    app.use route '/wiki/', app.set('wiki'), static()

# examples
require '../examples/list'
require '../examples/store'
require '../examples/upload'
require '../examples/template'
require '../examples/worker'
require '../examples/git'
app.configure () =>
    app.set 'examples', (root + 'examples-www/')
    app.use route '/', app.set('examples'), less()
    app.use route '/', app.set('examples'), sass()
    app.use route '/', app.set('examples'), nun()
    app.use route '/', app.set('examples'), static()

# git repositories
# perhaps self discover later
app.configure () =>
    app.set 'repositories', [
        path.normalize(root)
        path.normalize(root + '../BrainDump/')
        path.normalize(root + '../VoodooLabs/')
        path.normalize(root + '../Shard/')
        path.normalize(root + '../MediaRepository/')
    ]

# if nothing was matched show the error handler
app.configure () =>
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
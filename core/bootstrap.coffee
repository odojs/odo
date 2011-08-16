express = require 'express'
path = require 'path'
app = require './app'
inject = require 'pminject'
_ = require 'underscore'

inject.bind router: require 'lw-route'

inject.bind staticfilehandler: require 'lw-static'

inject.bind filehandlers: [
    require 'lw-sass'
    require 'lw-less'
    require 'lw-nun'
    require 'lw-static'
]

inject.bind viewhandler: require 'lw-view'

root = path.normalize(__dirname + '/')

# general configuration
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
    for filehandler in inject.all 'filehandlers'
        app.use (inject.one 'router') '/content/', app.set('content'), filehandler()

# normal www directory
app.configure () =>
    app.set 'www', (root + 'www/')
    app.use(inject.one('viewhandler')(
        search: [ app.set 'www' ]
    ))
    app.use app.router
    
    for filehandler in inject.all 'filehandlers'
        app.use (inject.one 'router') '/', app.set('www'), filehandler()

# wiki
require './services/wiki'
app.configure () =>
    app.set 'wiki', path.normalize(root + '../../BrainDump/wiki/')
    app.use (inject.one 'router') '/wiki/braindump.md.txt', path.normalize(root + '../../BrainDump/README.md'), inject.one('staticfilehandler')()
    app.use (inject.one 'router') '/wiki/lightweight.md.txt', path.normalize(app.set('root') + '../README.md'), inject.one('staticfilehandler')()
    
    for filehandler in inject.all 'filehandlers'
        app.use (inject.one 'router') '/wiki/', app.set('wiki'), filehandler()

# examples
require './examples/list'
require './examples/store'
require './examples/upload'
require './examples/template'
require './examples/worker'
require './examples/git'
app.configure () =>
    app.set 'examples', (root + 'examples-www/')
    for filehandler in inject.all 'filehandlers'
        app.use (inject.one 'router') '/', app.set('examples'), filehandler()

# git repositories
# perhaps self discover later
app.configure () =>
    app.set 'repositories', [
        path.normalize(root)
        path.normalize(root + '../../BrainDump/')
        path.normalize(root + '../../VoodooLabs/')
        path.normalize(root + '../../Shard/')
        path.normalize(root + '../../MediaRepository/')
    ]

# if nothing was matched show the error handler
app.configure () =>
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
express = require 'express'
path = require 'path'
app = require './app'
inject = require 'pminject'
_ = require 'underscore'

router = require 'lw-route'

root = path.normalize(__dirname + '/')

inject.bind 'root': root
inject.bind 'root.www': (root + 'www/')
inject.bind 'root.content': (root + 'content/')
inject.bind 'wiki.www': path.normalize(root + '../lw-wiki/www/')
inject.bind 'wiki.store': path.normalize(root + '../../BrainDump/wiki/')
inject.bind repositories: [
    path.normalize(root + '../')
    path.normalize(root + '../../BrainDump/')
    path.normalize(root + '../../VoodooLabs/')
    path.normalize(root + '../../Shard/')
    path.normalize(root + '../../MediaRepository/')
]

inject.bind app: app
inject.bind router: router
inject.bind staticfilehandler: require 'lw-static'
inject.bind filehandlers: [
    require 'lw-sass'
    require 'lw-less'
    require 'lw-nun'
    require 'lw-static'
]
inject.bind list: require 'lw-list'
inject.bind viewhandler: require 'lw-view'
inject.bind wiki: require 'lw-wiki'


require './examples/store'
require './examples/upload'
require './examples/worker'
require './examples/git'


# general configuration
app.configure () =>
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'

# user content
app.configure () =>
    for filehandler in inject.all 'filehandlers'
        app.use router '/content/', (inject.one 'root.content'), filehandler()

# normal www directory
app.configure () =>
    app.use(inject.one('viewhandler')(
        search: [ inject.one 'root.www' ]
    ))
    app.use app.router
    
    for filehandler in inject.all 'filehandlers'
        app.use router '/', (inject.one 'root.www'), filehandler()

# examples
app.configure () =>
    app.use router '/wiki/braindump.md.txt', path.normalize(root + '../../BrainDump/README.md'), inject.one('staticfilehandler')()
    app.use router '/wiki/lightweight.md.txt', path.normalize(root + '../README.md'), inject.one('staticfilehandler')()
    
    for filehandler in inject.all 'filehandlers'
        app.use router '/', (inject.one 'wiki.www'), filehandler()
        app.use router '/wiki/', (inject.one 'wiki.store'), filehandler()
        app.use router '/', (root + 'examples-www/'), filehandler()
        app.use router '/', (root + '../lw-list/www/'), filehandler()

# if nothing was matched show the error handler
app.configure () =>
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
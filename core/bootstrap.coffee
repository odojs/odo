express = require 'express'
path = require 'path'
inject = require 'pminject'
router = require 'lw-route'

root = path.normalize(__dirname + '/')


app = express.createServer()


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
inject.bind routes: [
    { from: '/', to: (inject.one 'root.www') }
    { from: '/', to: (inject.one 'wiki.www') }
    { from: '/wiki/', to: (inject.one 'wiki.store') }
    { from: '/', to: (root + 'examples-www/') }
    { from: '/', to: (root + '../lw-list/www/') }
    { from: '/', to: (root + '../lw-store/www/') }
    { from: '/', to: (root + '../lw-upload/www/') }
    { from: '/content/', to: (inject.one 'root.content') }
]

inject.bind staticroutes: [
    { from: '/wiki/braindump.md.txt', to: path.normalize(root + '../../BrainDump/README.md') }
    { from: '/wiki/lightweight.md.txt', to: path.normalize(root + '../README.md') }
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


require 'lw-store'
require 'lw-upload'
require 'lw-worker'
require 'lw-git'


# general configuration
app.configure () =>
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
        
    app.use(inject.one('viewhandler')(
        search: [ inject.one 'root.www' ]
    ))
    
    for mapping in inject.all 'staticroutes'
        app.use router mapping.from, mapping.to, inject.one('staticfilehandler')()
    
    for filehandler in inject.all 'filehandlers'
        for mapping in inject.all 'routes'
            app.use router mapping.from, mapping.to, filehandler()
            
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
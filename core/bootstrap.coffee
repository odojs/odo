express = require 'express'
path = require 'path'
inject = require 'pminject'
router = require 'lw-route'

app = express.createServer()


# Configuration
root = path.normalize(__dirname + '/')

inject.bind 'wiki.store': path.normalize root + '../../BrainDump/wiki/'

inject.bind repositories: [
    path.normalize root + '../'
    path.normalize root + '../../BrainDump/'
    path.normalize root + '../../VoodooLabs/'
    path.normalize root + '../../Shard/'
    path.normalize root + '../../MediaRepository/'
]

inject.bind routes: [
    { from: '/', to: root + 'www/' }
    { from: '/content/', to: root + 'content/' }
]

inject.bind staticroutes: [
    { from: '/wiki/braindump.md.txt', to: path.normalize root + '../../BrainDump/README.md' }
    { from: '/wiki/lightweight.md.txt', to: path.normalize root + '../README.md' }
]


# Middleware
inject.bind app: app
inject.bind router: router
inject.bind list: require 'lw-list'
inject.bind staticfilehandler: require 'lw-static'
inject.bind filehandlers: [
    require 'lw-sass'
    require 'lw-less'
    require 'lw-nun'
    require 'lw-static'
]
inject.bind viewhandler: require 'lw-view'


# Stuff that does things
inject.bind wiki: require 'lw-wiki'
inject.bind store: require 'lw-store'
inject.bind upload: require 'lw-upload'
inject.bind worker: require 'lw-worker'
inject.bind git: require 'lw-git'


# Piping it all together
app.configure () =>
    #app.use(express.logger());
    #app.use(express.bodyParser());
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
        
    app.use(inject.one('viewhandler')(
        search: (inject.all 'routes').map (route) -> return route.to
    ))
    
    for mapping in inject.all 'staticroutes'
        app.use router mapping.from, mapping.to, (inject.one 'staticfilehandler')()
    
    for filehandler in inject.all 'filehandlers'
        for mapping in inject.all 'routes'
            app.use router mapping.from, mapping.to, filehandler()
            
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true
    
app.listen 3000
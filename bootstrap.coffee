express = require 'express'
path = require 'path'
inject = require 'PMInject'
router = require './lw-route/route'

app = express.createServer()


#app.get('/', function(request, response) {
#   if (process.env.REDISTOGO_URL) {
#        var rtg   = require('url').parse(process.env.REDISTOGO_URL);
#        var redis = require('redis').createClient(rtg.port, rtg.hostname);
#        redis.auth(rtg.auth.split(':')[1]);
#    } else {
#        var redis = require('redis').createClient();
#    }
#
#    redis.set('foo', 'bar');
#    redis.get('foo', function(err, value) {
#        response.send('foo is: ' + value);
#        redis.end()
#    });
#});



# set this all up before, so the body parser can work
app.configure () =>
    #app.use express.logger()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
        secret: 'bob'
    
    app.use app.router


# Configuration
root = path.normalize(__dirname + '/')

#inject.bind 'wiki.store': path.normalize root + '../../BrainDump/wiki/'

#inject.bind repositories: [
#    path.normalize root + '../'
#    path.normalize root + '../../BrainDump/'
#    path.normalize root + '../../VoodooLabs/'
#    path.normalize root + '../../Shard/'
#    path.normalize root + '../../MediaRepository/'
#]

inject.bind routes: [
    { from: '/', to: root + 'www/' }
    { from: '/content/', to: root + 'content/' }
]

inject.bind staticroutes: []
#inject.bind staticroutes: [
#    { from: '/wiki/braindump.md.txt', to: path.normalize root + '../../BrainDump/README.md' }
#    { from: '/wiki/lightweight.md.txt', to: path.normalize root + '../README.md' }
#]


# Middleware
inject.bind app: app
inject.bind router: router
inject.bind list: require './lw-list/list'
inject.bind staticfilehandler: require './lw-static/static'
inject.bind filehandlers: [
    require './lw-sass/sass'
    require './lw-less/less'
    require './lw-nun/nun'
    require './lw-static/static'
]
inject.bind viewhandler: require './lw-view/view'


# Stuff that does things
#inject.bind wiki: require './lw-wiki/wiki'
#inject.bind store: require './lw-store/store'
#inject.bind upload: require './lw-upload/upload'
#inject.bind worker: require './lw-worker/worker'
#inject.bind git: require './lw-git/git'
#inject.bind auth: require './lw-auth/auth'


# Piping it all together
app.configure () =>
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
    
app.listen(process.env.PORT || 3000)
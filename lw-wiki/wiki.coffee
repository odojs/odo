fs = require 'fs'
path = require 'path'
inject = require 'pminject'

inject.bind routes: [
    { from: '/',  to: path.normalize(__dirname + '/www/') }
    { from: '/wiki/',  to: inject.one 'wiki.store' }
]

list = inject.one 'list'
app = inject.one 'app'

app.get '/services/wiki', (req, res, next) =>
    list (inject.one 'wiki.store'),
        type: 'file'
        ext: '.md.txt',
        (err, files) ->
            throw err if err?
            
            res.send files
        

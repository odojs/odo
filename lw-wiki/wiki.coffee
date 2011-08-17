fs = require 'fs'
inject = require 'pminject'

list = inject.one 'list'
app = inject.one 'app'

app.get '/services/wiki', (req, res, next) =>
    list (inject.one 'wiki.store'),
        type: 'file'
        ext: '.md.txt',
        (err, files) ->
            throw err if err?
            
            res.send files
        

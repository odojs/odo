fs = require('fs');
app = require '../core/app'
list = require '../core/list'

app.get '/services/wiki', (req, res, next) =>
    list (app.set 'wiki'),
        type: 'file'
        ext: '.md.txt',
        (err, files) ->
            throw err if err?
            
            res.send files
        

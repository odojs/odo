fs = require('fs');
app = require '../app'
list = require '../list'

app.get '/services/wiki', (req, res, next) =>
    list (app.set 'wiki'),
        type: 'file'
        ext: '.md.txt',
        (err, files) ->
            throw err if err?
            
            res.send files
        

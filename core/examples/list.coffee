fs = require('fs');
app = require '../app'
list = require '../list'

app.get '/examples/list', (req, res, next) =>
    if not req.query.dir?
        next()
        return
    
    list (app.set 'www') + req.query.dir,
        type: req.query.type
        ext: req.query.ext,
        (err, files) ->
            throw err if err?
            
            res.send files
        
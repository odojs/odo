path = require 'path'

inject = require 'pminject'
app = inject.one 'app'

inject.bind routes:
    from: '/'
    to: path.normalize(__dirname + '/www/')


app.post '/signin', (req, res, next) =>
    console.log req.body.username
    next()
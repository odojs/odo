app = require '../app'

app.get '/', (req, res, next) =>
    res.view 'index'
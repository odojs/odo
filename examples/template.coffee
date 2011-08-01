app = require '../core/app'

app.get '/', (req, res, next) =>
    res.view 'index'
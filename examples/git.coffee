app = require '../core/app'

app.get '/examples/git', (req, res, next) =>
    model =
        repositories: []
    
    (app.set 'repositories').forEach (repository) =>
        model.repositories.push
            path: repository
    
    res.view 'git', model
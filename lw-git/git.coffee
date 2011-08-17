async = require 'async'
inject = require 'pminject'

app = inject.one 'app'

Repo = (require 'git').Repo
Commit = (require 'git').Commit
# Blob = (require 'git').Blob

app.get '/examples/git', (req, res, next) =>
    model =
        repositories: []
    
    parseRepository = (path, cb) =>
        new Repo path, (err, repo) =>
            if err?
                next()
            repo.status (err, status) =>
                if err?
                    next()
                files = status.files
                model.repositories.push
                    path: path
                    status: files.map (file) => return path: file.path
                cb()
    async.forEach (inject.all 'repositories'), parseRepository, (err) =>
        res.view 'git', model
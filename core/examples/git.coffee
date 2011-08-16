app = require '../app'
async = require 'async'

Repo = (require 'git').Repo
Commit = (require 'git').Commit
# Blob = (require 'git').Blob

app.get '/examples/git', (req, res, next) =>
    model =
        repositories: []
    
    parseRepository = (path, cb) =>
        new Repo path, (err, repo) =>
            repo.status (err, status) =>
                files = status.files
                model.repositories.push
                    path: path
                    status: files.map (file) => return path: file.path
                cb()
    async.forEach (app.set 'repositories'), parseRepository, (err) =>
        res.view 'git', model
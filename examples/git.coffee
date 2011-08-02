app = require '../core/app'
treeeater = require 'node-treeeater'

app.get '/examples/git', (req, res, next) =>
    git = new treeeater cwd: app.set 'root'
    git.trees 'HEAD', (trees) ->
        coffee = []
        tree = git.tree_hierachy(trees)
        #console.log tree
        for stuff in tree
            if stuff.type == 'tree'
                for more_stuff in stuff
                    if '.coffee' in more_stuff.path
                        coffee.push more_stuff
        console.log "#{coffee.length} coffee files in level 1 subfolders"
    git.status (status) ->
        console.log status
        res.send 'Done'
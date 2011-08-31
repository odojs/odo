path = require 'path'
nun = require 'lw-nun'

module.exports = (options) =>
    return (req, res, next) =>
        res.view = (name, model) =>
            if not options.search instanceof Array
                options.search = [options.search]
            
            matchedLocations = options.search.map((searchPath) =>
                return path.normalize searchPath + name + '.nun')
            .filter((searchPath) => return path.existsSync searchPath)
            
            if matchedLocations.length == 0
                throw new Error('View not found, searched\n    * ' + options.search.join('\n    * '));
            
            root = matchedLocations[0]
            
            model = model ? {}
            model.req = req
            
            # render as nun
            nun.render(
                root,
                # take an existing view model and extend it
                # with some defaults
                model, {}, (err, output) =>
                    if err?
                        throw err
                
                    buffer = ''
                    output.on 'data', (data) => buffer += data
                    output.on 'end', () =>
                        res.header 'Content-Type', 'text/html'
                        res.send buffer
            )
        next()
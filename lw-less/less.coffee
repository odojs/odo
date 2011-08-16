path = require 'path'
less = require 'less'
fs = require 'fs'

module.exports = (options) =>
    return (req, res, next) =>
        # only interested in known content types
        extension = req.url.split('.').pop()
        if extension != 'less'
            next()
            return
        
        # is it a file?
        path.exists req.route.path, (exists) =>
            if not exists
                next()
                return
            
            # from the url get the path and filename
            
            dir = path.dirname req.route.path
            filename = path.basename req.route.path
            
            fs.readFile req.route.path, 'utf8', (err, data) =>
                if err
                    next()
                    return
                
                parser = new (less.Parser)({
                    paths: [dir]
                    filename: filename
                });
                
                parser.parse data, (err, tree) =>
                    if err
                        next()
                        return
                    res.header 'Content-Type', 'text/css'
                    res.send tree.toCSS options
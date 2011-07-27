path = require('path');
nun = require('nun');

module.exports = (options) =>
    return (req, res, next) =>
        url = req.url
        
        if url[req.url.length - 1] == '/'
            url += 'index'
        
        url += '.nun'
        
        root = req.route.map + url
        
        # only interested in known content types
        extension = url.split('.').pop()
        if extension != 'nun'
            next()
            return
        
        # is it a file?
        path.exists root, (exists) =>
            if not exists
                next()
                return
            
            model = req.model ? {}
            model.req = req
            
            # render as nun
            nun.render(
                root,
                # take an existing view model and extend it
                # with some defaults
                model, {}, (err, output) =>
                    if err
                        next(err)
                        return
                
                    buffer = ''
                    output.on 'data', (data) => buffer += data
                    output.on 'end', () =>
                        res.header 'Content-Type', 'text/html'
                        res.send buffer
            )
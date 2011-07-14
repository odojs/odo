var fs = require('fs');
var nun = require('nun');

var contentTypes = {
    'html': 'text/html',
    'txt': 'text/plain'
};

exports = module.exports = function static(options) {
    return function(req, res, next, route) {
        if (route.url[route.url.length - 1] == '/') {
            route.url += 'index.html';
            route.path = route.map + route.url;
        }
        
        // only interested in known content types
        var extension = route.url.split('.').pop();
        if (!contentTypes[extension]) {
            next();
            return;
        }
        
        var contentType = contentTypes[extension];
        
        // is it a file?
        fs.stat(route.path, function (err, stat) {
            if (err || !stat.isFile()) {
                next(err);
                return;
            }
            
            // render as nun
            nun.render(
                route.path,
                // take an existing view model and extend it
                // with some defaults
                (req.model || {}).extend(
                {
                    req: req,
                    route: route
                }),
                {},
                function(err, output) {
                    if (err) {
                        next(err);
                        return;
                    }
                
                    var buffer = '';
                    output
                            .on('data', function(data) { buffer += data; })
                            .on('end', function() {
                        res.header('Content-Type', contentType);
                        res.send(buffer);
                    });
                }
            );
        });
    };
};
var path = require('path');
var less = require('less');
var fs = require('fs');

exports = module.exports = function static(options) {
    return function(req, res, next) {
        // only interested in known content types
        var extension = req.url.split('.').pop();
        if (extension != 'less') {
            next();
            return;
        }
        
        // is it a file?
        path.exists(req.route.path, function (exists) {
            if (!exists) {
                next();
                return;
            }
            
            // from the url get the path and filename
            
            var dir = path.dirname(req.route.path);
            var filename = path.basename(req.route.path);
            
            fs.readFile(req.route.path, 'utf8', function (err, data) {
                if (err) {
                    next();
                    return;
                }
                
                var parser = new (less.Parser)({
                    paths: [dir],
                    filename: filename
                });
                
                parser.parse(data, function (err, tree) {
                    if (err) {
                        next();
                        return;
                    }
                    res.header('Content-Type', 'text/css');
                    res.send(tree.toCSS(options));
                });
            });
        });
    };
};
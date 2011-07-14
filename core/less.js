var fs = require('fs');
var path = require('path');
var less = require('less');

exports = module.exports = function static(options) {
    return function(req, res, next, route) {
        // only interested in known content types
        var extension = route.url.split('.').pop();
        if (extension != 'less') {
            next();
            return;
        }
        
        // is it a file?
        fs.stat(route.path, function (err, stat) {
            if (err || !stat.isFile()) {
                next();
                return;
            }
            
            // from the url get the path and filename
            
            var dir = path.dirname(route.path);
            var filename = path.basename(route.path);
            
            fs.readFile(route.path, 'utf8', function (err, data) {
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
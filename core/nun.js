var path = require('path');
var nun = require('nun');

exports = module.exports = function static(options) {
    return function(req, res, next) {
        var url = req.url;
        
        if (url[req.url.length - 1] == '/') {
            url += 'index';
        }
        
        url += '.nun';
        
        var root = req.route.map + url;
        
        // only interested in known content types
        var extension = url.split('.').pop();
        if (extension != 'nun') {
            next();
            return;
        }
        
        // is it a file?
        path.exists(root, function (exists) {
            if (!exists) {
                next();
                return;
            }
            
            // render as nun
            nun.render(
                root,
                // take an existing view model and extend it
                // with some defaults
                (req.model || {}).extend({ req: req }), {}, function(err, output) {
                    if (err) {
                        next(err);
                        return;
                    }
                
                    var buffer = '';
                    output
                            .on('data', function(data) { buffer += data; })
                            .on('end', function() {
                        res.header('Content-Type', 'text/html');
                        res.send(buffer);
                    });
                }
            );
        });
    };
};
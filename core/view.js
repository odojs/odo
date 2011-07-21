var path = require('path');
var nun = require('nun');

exports = module.exports = function static(options) {
    return function(req, res, next) {
        res.view = function(name, model) {
            var root = path.normalize(app.set('views') + name + '.nun');
            // work out where the view is
            // render, etc.
            
            // is it a file?
            path.exists(root, function (exists) {
                if (!exists)
                    throw new Error('View not found at ' + root);
                
                // render as nun
                nun.render(
                    root,
                    // take an existing view model and extend it
                    // with some defaults
                    (model || {}).extend({ req: req }), {}, function(err, output) {
                        if (err)
                            throw err;
                    
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
        }
        next();
    };
};
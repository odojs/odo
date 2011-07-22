var path = require('path');
var nun = require('nun');

exports = module.exports = function static(options) {
    return function(req, res, next) {
        res.view = function(name, model) {
            if (!(options.search instanceof Array))
                options.search = [options.search];
            
            var matchedLocations = options.search.map(function(searchPath) {
                return path.normalize(searchPath + name + '.nun');
            }).filter(function(searchPath) {
                return path.existsSync(searchPath);
            });
            
            if (matchedLocations.length == 0)
                throw new Error('View not found, searched\n    * ' + options.search.join('\n    * '));
            
            var root = matchedLocations[0];
            
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
        }
        next();
    };
};
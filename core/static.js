var paperboy = require('paperboy');

exports = module.exports = function static(root, map, options){
    options = options || {};
    
    // root required
    if (!root || !map) throw new Error('static() root and map required');
    
    //console.log('Route: ' + root + ' => ' + map);
    return function(req, res, next) {
        // root is longer than url - couldn't possibly match
        if (root.length > req.url) {
            next();
            return;
        }
        
        // root doesn't match the start of url - not matched
        if (req.url.substr(0, root.length) != root) {
            next();
            return;
        }
        
        // chop off the matched part of the url
        var url = req.url.substr(root.length - 1);
        
        options.path = url;
        options.root = map;
        
        //console.log(root + '\n    =>' + req.url + '\n    =>' + url);
        paperboy
            .deliver(map, req.extend({ url: url }), res)
            .otherwise(function () {
                next();
            });
        
        //return require('../node_modules/connect/lib/middleware/static.js')
        //    .send(req, res, next, options);
    };
};
exports = module.exports = function static(root, map, callback) {
    // root required
    if (!root || !map) throw new Error('route() root and map required');
    
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
        
        //console.log(root + '\n    =>' + req.url + '\n    =>' + url + '\n    =>' + map);
        
        callback(req, res, next, {
            root: root,
            map: map,
            url: url,
            path: map + url
        });
    };
};
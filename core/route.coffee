path = require 'path'

module.exports = (root, map, callback) =>
    # root required
    if not (root? and map?)
        throw new Error('route() root and map required')
    
    #console.log 'Route: ' + root + ' => ' + map
    return (req, res, next) =>
        # root is longer than url - couldn't possibly match
        if root.length > req.url
            next()
            return
        
        # root doesn't match the start of url - not matched
        if req.url.substr(0, root.length) != root
            next()
            return
        
        if map.substring(map.length - 1) != '/'
            # direct file mapping, continue
            url = path.basename map
            map = path.dirname map
        else
            # chop off the matched part of the url
            url = req.url.substr root.length - 1
        
        data = 
            url: url
            route:
                root: root
                map: map
                url: url
                path: map + url
        
        #console.log root + '\n    =>' + req.url + '\n    =>' + url + '\n    =>' + map
        callback(req extends data, res, next);
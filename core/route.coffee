path = require 'path'
_ = require 'underscore'

module.exports = (root, map, callback) =>
    # root required
    if not (root? and map?)
        throw new Error('route() root and map required')
    
    #console.log 'Route: ' + root + ' => ' + map
    return (req, res, next) =>
        mapref = map
        url = ''
        
        # root is longer than url - couldn't possibly match
        if root.length > req.url
            next()
            return
        
        # root doesn't match the start of url - not matched
        if req.url.substr(0, root.length) != root
            next()
            return
        
        if mapref.substring(mapref.length - 1) != '/'
            # direct file mapping, continue
            url = path.basename mapref
            mapref = path.dirname mapref
        else
            # chop off the matched part of the url
            url = req.url.substr root.length - 1
        
        data = 
            url: url
            route:
                root: root
                map: mapref
                url: url
                path: mapref + url
        
        newreq = _.clone req
        newreq = _.extend newreq, data
        
        #console.log root + '\n    =>' + req.url + '\n    =>' + url + '\n    =>' + map
        callback newreq, res, next
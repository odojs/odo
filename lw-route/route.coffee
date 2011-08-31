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
    

#I want a file: /adir/file.txt
#What are all the things in this directory: /adir/
#
#
#
#
#
#maps (in order)
#
#first should be the current 'app'
#then all the modules
#
#
#directory maps
#
#/ -> ~/Source/lightweight/
#/ -> ~/Source/lightweight/lw-wiki/www/
#/ -> ~/Source/lightweight/lw-upload/www/
#
#
#file maps
#
#/wiki/lightweight.md.txt -> ~/Source/lightweight/README.md
#
#
#
#pseudo code:
#
#'basically just extending router'
#
#
#
#
#input = url
#
#for from, to of filemaps
#    if from == url
#        check if to is a valid path to a file
#            return to
#        
#
#for from, to of dirmap
#    if !url.startswith(from)
#        continue
#    
#    map = to + url.substring from.length
#    
#    check if map is a valid path to a file
#        return map
#
#return null
#
#
#
#
#input = url
#
#results = []
#
#for from, to of filemaps
#    if !url.startswith(from)
#        continue
#    
#    file = url.substring from.length
#    
#    if file.contains '/'
#        continue
#    
#    results.push to + file
#
#for from, to of dirmap
#    if !url.startswith(from)
#        continue
#    
#    dir = url.substring from.length
#    
#    if dir.count '/' > 1
#        continue
#    
#    results.push dir
#
#return results
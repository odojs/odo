dropbox = require 'dropbox'
path = require 'path'
_ = require 'underscore'

sectionpaths = []

utils = 
  extension: '.md'

  maketitle: (file) ->
    result = path.basename file
    result = result.substr 0, result.length - utils.extension.length
    
  errors: {
    '${dropbox.ApiError.INVALID_TOKEN}': 'Invalid token'
    '${dropbox.ApiError.NOT_FOUND}': 'Not found'
    '${dropbox.ApiError.OVER_QUOTA}': 'Over quota'
    '${dropbox.ApiError.RATE_LIMITED}': 'Rate limited'
    '${dropbox.ApiError.NETWORK_ERROR}': 'Network error'
    '${dropbox.ApiError.INVALID_PARAM}': 'Invalid parameter'
    '${dropbox.ApiError.OAUTH_ERROR}': 'OAuth Error'
    '${dropbox.ApiError.INVALID_METHOD}': 'Invalid method'
  }

module.exports =
  configure: (app) ->
    app.postal.channel().subscribe 'section.new', (section) ->
      sectionpaths.push section.path

    app.postal.channel().subscribe 'section.changepath', (message) ->
      sectionpaths.remove message.oldpath
      sectionpaths.push message.newpath

    app.fetch.bind 'sectionpaths', 'all', (app, params, cb) ->
      cb null, sectionpaths

    pagetitles = {}
    app.fetch.bind 'pagetitles', 'all', (app, params, cb) ->
      # check the cache
      req = app.inject.one 'req'
      
      if !req.user?
        cb null, []
        return
      
      if pagetitles[req.user]?
        cb null, pagetitles[req.user]
        return
      
      client = app.inject.one('dropbox.client')()

      if !client?
        cb null, []
        return

      # fetch sections
      await app.fetch.exec 'sectionpaths', 'all', app, null, defer error, sections
      throw error if error?

      sections = for section in sections
        path: section
        file: path.basename section
        title: path.basename section

      # fetch section contents from dropbox
      await
        for section in sections
          client.readdir section.path, defer error, section.pages
      
          if error?
            cb utils.errors[error]
            return

      # transform
      for section in sections
        section.pages = _(section.pages)
          .filter((page) ->
            page.endsWith utils.extension)
          .map((page) ->
            file: page
            title: utils.maketitle page)

      pagetitles[req.user] = sections
      cb null, sections
      
    app.fetch.bind 'pagecontents', 'bypath', (app, params, cb) ->
      client = app.inject.one('dropbox.client')()

      if !client? or !params.path or !params.path.endsWith utils.extension
        cb null, []
        return
      
      await client.readFile params.path, defer error, data
      
      if error?
        cb utils.errors[error]
        return
      
      cb null,
        path: params.path
        file: path.basename params.path
        title: utils.maketitle params.path
        contents: data
    
    app.fetch.bind 'pagecontents', 'bysectionandpage', (app, params, cb) ->
      client = app.inject.one('dropbox.client')()

      if !client?
        cb null, []
        return
      
      file = path.join params.section, params.page + utils.extension
      
      await client.readFile file, defer error, data
      
      if error?
        cb utils.errors[error]
        return
      
      cb null,
        path: file
        file: path.basename file
        title: utils.maketitle file
        contents: data

  init: (app) ->
    app.postal.publish 
      topic: 'section.new'
      data:
        title: 'Patterns and Practices'
        path: 'Knowledge/Patterns and Practices'

    app.postal.publish 
      topic: 'section.new'
      data:
        title: 'Work'
        path: 'Knowledge/Work'
      
    app.postal.publish 
      topic: 'section.new'
      data:
        title: 'Brain Dump'
        path: 'Knowledge/Brain Dump'
      
    app.postal.publish 
      topic: 'section.new'
      data:
        title: 'Leader of Men'
        path: 'Knowledge/Leader of Men'
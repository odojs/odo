express = require 'express'
dropbox = require 'dropbox-redis-cache'
tapinto = require 'tapinto'

module.exports =
	init: (app) ->
		app.get '/test', (req, res) ->
      
      if !req.user?
        res.send 'Not logged in'
        return

      client = new dropbox.Client
        key: app.get 'dropbox key'
        secret: app.get 'dropbox secret'
        token: req.user.token
        tokenSecret: req.user.tokenSecret
        uid: req.user._json.uid
      
      client.readdir '/Knowledge/Brain Dump', (error, pages) ->
        res.send pages.join ', '

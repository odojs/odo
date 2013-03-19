express = require 'express'
passport = require 'passport'
dropbox = require 'dropbox'
DropboxStrategy = require('passport-dropbox').Strategy
_ = require 'underscore'


module.exports =
  configure: (app) ->
    # Passport session setup
    # ----------------------
    # To support persistent login sessions, Passport needs to be able to serialize users into and deserialize users out of the session. Typically, this will be as simple as storing the user ID when serializing, and finding the user by ID when deserializing.  However, since this example does not have a database of user records, the complete Dropbox profile is serialized and deserialized.
    passport.serializeUser (user, done) ->
      done(null, user)

    passport.deserializeUser (obj, done) ->
      done(null, obj)

    # Use the DropboxStrategy within Passport
    # Strategies in passport require a `verify` function, which accept credentials (in this case, a token, tokenSecret, and Dropbox profile), and invoke a callback with a user object.
    passport.use(new DropboxStrategy({
        consumerKey: app.get 'dropbox key'
        consumerSecret: app.get 'dropbox secret'
        callbackURL: app.get 'dropbox callback'
      },
      (token, tokenSecret, profile, done) ->
        # To keep the example simple, the user's Dropbox profile is returned to represent the logged-in user.  In a typical application, you would want to associate the Dropbox account with a user record in your database, and return that user instead.
        done null, _.extend profile, {
          token: token
          tokenSecret: tokenSecret
        }
    ))

    # Simple route middleware to ensure user is authenticated.
    # Use this route middleware on any resource that needs to be protected. If the request is authenticated (typically via a persistent login session), the request will proceed.  Otherwise, the user will be redirected to the login page.
    app.ensureAuth = (req, res, next) ->
      return next() if req.isAuthenticated()
      res.redirect app.get 'dropbox fail'
    
  init: (app) ->
    # GET /auth/dropbox
    # Use passport.authenticate() as route middleware to authenticate the request.# The first step in Dropbox authentication will involve redirecting the user to dropbox.com. After authorization, Dropbox will redirect the user back to this application at /auth/dropbox/callback
    app.get '/auth/dropbox',
      passport.authenticate('dropbox'),
      (req, res) ->
        # The request will be redirected to Dropbox for authentication, so this failureRedirectnction will not be called.

    # GET /auth/dropbox/callback
    # Use passport.authenticate() as route middleware to authenticate the request.  If authentication fails, the user will be redirected back to the login page.  Otherwise, the primary route function function will be called, which, in this example, will redirect the user to the home page.
    app.get '/auth/dropbox/callback', 
      passport.authenticate('dropbox', { failureRedirect: app.get 'dropbox fail' }),
      (req, res) ->
        res.redirect app.get 'dropbox sign-in'

    app.get '/auth/dropbox/sign-out', (req, res) ->
      req.logout()
      res.redirect app.get 'dropbox sign-out'
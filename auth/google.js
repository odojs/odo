// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['passport', 'passport-google', 'odo/config', 'odo/messaging/hub', 'node-uuid', 'redis', 'odo/express/app'], function(passport, passportgoogle, config, hub, uuid, redis, app) {
    var GoogleAuthentication, db;
    db = redis.createClient();
    return GoogleAuthentication = (function() {
      function GoogleAuthentication() {
        this.signin = __bind(this.signin, this);
        this.projection = __bind(this.projection, this);
        this.web = __bind(this.web, this);
      }

      GoogleAuthentication.prototype.web = function() {
        passport.use(new passportgoogle.Strategy({
          realm: config.passport.google['realm'],
          returnURL: config.passport.google['host'] + '/odo/auth/google/callback',
          passReqToCallback: true
        }, this.signin));
        app.get('/odo/auth/google', passport.authenticate('google'));
        return app.get('/odo/auth/google/callback', function(req, res, next) {
          return passport.authenticate('google', function(err, user, info) {
            var _ref, _ref1;
            if (err != null) {
              return next(err);
            }
            if (!user) {
              if (((_ref = config.odo.auth) != null ? (_ref1 = _ref.google) != null ? _ref1.failureRedirect : void 0 : void 0) != null) {
                return res.redirect(config.odo.auth.google.failureRedirect);
              }
              return res.redirect('/#auth/google/failure');
            }
            return req.logIn(user, function(err) {
              var returnTo, _ref2, _ref3, _ref4;
              if (err != null) {
                return next(err);
              }
              if (((_ref2 = req.session) != null ? _ref2.returnTo : void 0) != null) {
                returnTo = req.session.returnTo;
                delete req.session.returnTo;
                return res.redirect(returnTo);
              }
              if (((_ref3 = config.odo.auth) != null ? (_ref4 = _ref3.google) != null ? _ref4.successRedirect : void 0 : void 0) != null) {
                return res.redirect(config.odo.auth.google.successRedirect);
              }
              return res.redirect('/#auth/google/success');
            });
          })(req, res, next);
        });
      };

      GoogleAuthentication.prototype.projection = function() {
        hub.receive('userGoogleConnected', (function(_this) {
          return function(event, cb) {
            return db.hset("" + config.odo.domain + ":usergoogle", event.payload.profile.id, event.payload.id, function() {
              return cb();
            });
          };
        })(this));
        return hub.receive('userGoogleDisconnected', (function(_this) {
          return function(event, cb) {
            return db.hdel("" + config.odo.domain + ":usergoogle", event.payload.profile.id, function() {
              return cb();
            });
          };
        })(this));
      };

      GoogleAuthentication.prototype.signin = function(req, identifier, profile, done) {
        var userid;
        userid = null;
        profile.id = identifier;
        return this.get(profile.id, (function(_this) {
          return function(err, userid) {
            var user;
            if (err != null) {
              done(err);
              return;
            }
            if ((req.user != null) && (userid != null) && req.user.id !== userid) {
              done(null, false, {
                message: 'This Google account is connected to another Blackbeard account'
              });
              return;
            }
            if (req.user != null) {
              console.log('user already exists, connecting google to user');
              userid = req.user.id;
              hub.send({
                command: 'connectGoogleToUser',
                payload: {
                  id: userid,
                  profile: profile
                }
              });
            } else if (userid == null) {
              console.log('no user exists yet, creating a new id');
              userid = uuid.v1();
              hub.send({
                command: 'startTrackingUser',
                payload: {
                  id: userid,
                  profile: profile
                }
              });
              hub.send({
                command: 'connectGoogleToUser',
                payload: {
                  id: userid,
                  profile: profile
                }
              });
            } else {
              hub.send({
                command: 'connectGoogleToUser',
                payload: {
                  id: userid,
                  profile: profile
                }
              });
            }
            user = {
              id: userid,
              profile: profile
            };
            return done(null, user);
          };
        })(this));
      };

      GoogleAuthentication.prototype.get = function(id, callback) {
        return db.hget("" + config.odo.domain + ":usergoogle", id, (function(_this) {
          return function(err, data) {
            if (err != null) {
              callback(err);
              return;
            }
            if (data != null) {
              callback(null, data);
              return;
            }
            return db.hget("" + config.odo.domain + ":usergoogle", id, function(err, data) {
              if (err != null) {
                callback(err);
                return;
              }
              return callback(null, data);
            });
          };
        })(this));
      };

      return GoogleAuthentication;

    })();
  });

}).call(this);

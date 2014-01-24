// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['passport', 'passport-google', 'odo/infra/config', 'odo/infra/hub', 'node-uuid', 'redis', 'odo/express/app'], function(passport, passportgoogle, config, hub, uuid, redis, app) {
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
        return app.get('/odo/auth/google/callback', passport.authenticate('google', {
          successRedirect: '/#auth/google/success',
          failureRedirect: '/#auth/google/failure'
        }));
      };

      GoogleAuthentication.prototype.projection = function() {
        var _this = this;
        hub.receive('userGoogleConnected', function(event, cb) {
          return db.hset("" + config.odo.domain + ":usergoogle", event.payload.profile.id, event.payload.id, function() {
            return cb();
          });
        });
        return hub.receive('userGoogleDisconnected', function(event, cb) {
          return db.hdel("" + config.odo.domain + ":usergoogle", event.payload.profile.id, function() {
            return cb();
          });
        });
      };

      GoogleAuthentication.prototype.signin = function(req, identifier, profile, done) {
        var userid,
          _this = this;
        userid = null;
        profile.id = identifier;
        return this.get(profile.id, function(err, userid) {
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
        });
      };

      GoogleAuthentication.prototype.get = function(id, callback) {
        var _this = this;
        return db.hget("" + config.odo.domain + ":usergoogle", id, function(err, data) {
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
        });
      };

      return GoogleAuthentication;

    })();
  });

}).call(this);

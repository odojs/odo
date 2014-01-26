// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['passport', 'passport-facebook', 'odo/config', 'odo/messaging/hub', 'node-uuid', 'redis', 'odo/express/app'], function(passport, passportfacebook, config, hub, uuid, redis, app) {
    var FacebookAuthentication, db;
    db = redis.createClient();
    return FacebookAuthentication = (function() {
      function FacebookAuthentication() {
        this.signin = __bind(this.signin, this);
        this.projection = __bind(this.projection, this);
        this.web = __bind(this.web, this);
      }

      FacebookAuthentication.prototype.web = function() {
        passport.use(new passportfacebook.Strategy({
          clientID: config.passport.facebook['app id'],
          clientSecret: config.passport.facebook['app secret'],
          callbackURL: config.passport.facebook['host'] + '/odo/auth/facebook/callback',
          passReqToCallback: true
        }, this.signin));
        app.get('/odo/auth/facebook', passport.authenticate('facebook'));
        app.get('/odo/auth/facebook/callback', passport.authenticate('facebook', {
          successRedirect: '/#auth/facebook/success',
          failureRedirect: '/#auth/facebook/failure'
        }));
        return app.get('/odo/auth/facebook');
      };

      FacebookAuthentication.prototype.projection = function() {
        var _this = this;
        hub.receive('userFacebookConnected', function(event, cb) {
          return db.hset("" + config.odo.domain + ":userfacebook", event.payload.profile.id, event.payload.id, function() {
            return cb();
          });
        });
        return hub.receive('userFacebookDisconnected', function(event, cb) {
          return db.hdel("" + config.odo.domain + ":userfacebook", event.payload.profile.id, function() {
            return cb();
          });
        });
      };

      FacebookAuthentication.prototype.signin = function(req, accessToken, refreshToken, profile, done) {
        var userid,
          _this = this;
        userid = null;
        return this.get(profile.id, function(err, userid) {
          var user;
          if (err != null) {
            done(err);
            return;
          }
          if ((req.user != null) && (userid != null) && req.user.id !== userid) {
            done(null, false, {
              message: 'This Facebook account is connected to another Blackbeard account'
            });
            return;
          }
          if (req.user != null) {
            console.log('user already exists, connecting facebook to user');
            userid = req.user.id;
            hub.send({
              command: 'connectFacebookToUser',
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
              command: 'connectFacebookToUser',
              payload: {
                id: userid,
                profile: profile
              }
            });
            hub.send({
              command: 'assignDisplayNameToUser',
              payload: {
                id: userid,
                displayName: profile.displayName
              }
            });
          } else {
            hub.send({
              command: 'connectFacebookToUser',
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

      FacebookAuthentication.prototype.get = function(id, callback) {
        var _this = this;
        return db.hget("" + config.odo.domain + ":userfacebook", id, function(err, data) {
          if (err != null) {
            callback(err);
            return;
          }
          if (data != null) {
            callback(null, data);
            return;
          }
          return db.hget("" + config.odo.domain + ":userfacebook", id, function(err, data) {
            if (err != null) {
              callback(err);
              return;
            }
            return callback(null, data);
          });
        });
      };

      return FacebookAuthentication;

    })();
  });

}).call(this);

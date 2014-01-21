// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['module', 'passport', 'odo/config', 'redis', 'odo/projections/userprofile', 'odo/hub', 'node-uuid'], function(module, passport, config, redis, UserProfile, hub, uuid) {
    var Auth, db;
    db = redis.createClient();
    return Auth = (function() {
      function Auth() {
        this.init = __bind(this.init, this);
        this.configure = __bind(this.configure, this);
        var _this = this;
        this.receive = {
          userHasEmailAddress: function(event, cb) {
            return db.hset("" + config.odo.domain + ":useremail", event.payload.email, event.payload.id, function() {
              return cb();
            });
          },
          userHasVerifyEmailAddressToken: function(event, cb) {
            var key;
            key = "" + config.odo.domain + ":emailverificationtoken:" + event.payload.email + ":" + event.payload.token;
            console.log(key);
            return db.multi().set(key, event.payload.id).expire(key, 60 * 60 * 24).exec(function(err, replies) {
              if (err != null) {
                console.log(err);
                cb();
                return;
              }
              return cb();
            });
          }
        };
      }

      Auth.prototype.configure = function(app) {
        app.route('/odo', app.modulepath(module.uri) + '/auth-public');
        app.use(passport.initialize());
        app.use(passport.session());
        passport.serializeUser(function(user, done) {
          return done(null, user.id);
        });
        return passport.deserializeUser(function(id, done) {
          return new UserProfile().get(id, done);
        });
      };

      Auth.prototype.init = function(app) {
        var _this = this;
        app.get('/odo/auth/signout', function(req, res) {
          req.logout();
          return res.redirect('/');
        });
        app.get('/odo/auth/user', function(req, res) {
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          return res.send(req.user);
        });
        app.get('/odo/auth/forgot', function(req, res) {
          if (req.query.email == null) {
            res.send(400, 'Email address required');
            return;
          }
          return db.hget("" + config.odo.domain + ":useremail", req.query.email, function(err, userid) {
            if (err != null) {
              console.log(err);
              res.send(500, 'Woops');
              return;
            }
            if (userid == null) {
              res.send({
                account: false,
                message: 'No account found for this email address'
              });
              return;
            }
            return new UserProfile().get(userid, function(err, user) {
              if (err != null) {
                res.send(500, 'Couldn\'t find user');
                return;
              }
              return res.send({
                account: true,
                local: user.local != null,
                facebook: user.facebook != null,
                google: user.google != null,
                twitter: user.twitter != null,
                username: user.username != null,
                message: 'Account found'
              });
            });
          });
        });
        app.post('/odo/auth/verifyemail', function(req, res) {
          var token;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          if (req.body.email == null) {
            res.send(400, 'Email address required');
            return;
          }
          token = uuid.v1();
          console.log("createVerifyEmailAddressToken " + token);
          hub.send({
            command: 'createVerifyEmailAddressToken',
            payload: {
              id: req.user.id,
              email: req.body.email,
              token: uuid.v1()
            }
          });
          return res.send('Done');
        });
        app.get('/odo/auth/checkemailverificationtoken', function(req, res) {
          var key;
          if (req.user == null) {
            res.send(403, 'Authentication required');
            return;
          }
          if (req.query.email == null) {
            res.send(400, 'Email address required');
            return;
          }
          if (req.query.token == null) {
            res.send(400, 'Token required');
            return;
          }
          key = "" + config.odo.domain + ":emailverificationtoken:" + req.query.email + ":" + req.query.token;
          return db.get(key, function(err, userid) {
            if (err != null) {
              console.log(err);
              res.send(500, 'Woops');
              return;
            }
            if (userid == null) {
              res.send({
                isValid: false,
                message: 'Token not valid'
              });
              return;
            }
            if (req.user.id !== userid) {
              res.send(403, 'authentication required');
              return;
            }
            return res.send({
              isValid: true,
              message: 'Token valid'
            });
          });
        });
        return app.post('/odo/auth/emailverified', function(req, res) {
          var key;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          if (req.body.email == null) {
            res.send(400, 'Email address required');
            return;
          }
          if (req.body.token == null) {
            res.send(400, 'Token required');
            return;
          }
          key = "" + config.odo.domain + ":emailverificationtoken:" + req.body.email + ":" + req.body.token;
          return db.get(key, function(err, userid) {
            if (err != null) {
              console.log(err);
              res.send(500, 'Woops');
              return;
            }
            if (userid == null) {
              res.send(400, 'Token not valid');
              return;
            }
            if (req.user.id !== userid) {
              res.send(403, 'authentication required');
              return;
            }
            hub.send({
              command: 'assignEmailAddressToUser',
              payload: {
                id: userid,
                email: req.body.email,
                token: req.body.token
              }
            });
            return db.del(key, function(err, reply) {
              if (err != null) {
                console.log(err);
                res.send(500, 'Woops');
                return;
              }
              return res.send('Done');
            });
          });
        });
      };

      return Auth;

    })();
  });

}).call(this);

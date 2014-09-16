// Generated by CoffeeScript 1.8.0
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['module', 'passport', 'odo/config', 'odo/redis', 'odo/hub', 'node-uuid', 'odo/express', 'odo/restify', 'odo/inject'], function(module, passport, config, redis, hub, uuid, express, restify, inject) {
  var Auth;
  return Auth = (function() {
    function Auth() {
      this.assigndisplayname = __bind(this.assigndisplayname, this);
      this.emailverified = __bind(this.emailverified, this);
      this.checkemailverificationtoken = __bind(this.checkemailverificationtoken, this);
      this.verifyemail = __bind(this.verifyemail, this);
      this.forgot = __bind(this.forgot, this);
      this.projection = __bind(this.projection, this);
      this.api = __bind(this.api, this);
      this.web = __bind(this.web, this);
      this.db = __bind(this.db, this);
    }

    Auth.prototype.db = function() {
      if (this._db != null) {
        return this._db;
      }
      return this._db = redis();
    };

    Auth.prototype.web = function() {
      express.use(passport.initialize());
      express.use(passport.session());
      passport.serializeUser(function(user, done) {
        return done(null, user.id);
      });
      passport.deserializeUser(function(id, done) {
        return inject.one('odo user by id')(id, done);
      });
      express.get('/odo/auth/signout', this.signout);
      express.get('/odo/auth/user', this.user);
      express.get('/odo/auth/forgot', this.forgot);
      express.post('/odo/auth/verifyemail', this.verifyemail);
      express.get('/odo/auth/checkemailverificationtoken', this.checkemailverificationtoken);
      express.post('/odo/auth/emailverified', this.emailverified);
      return express.post('/odo/auth/assigndisplayname', this.assigndisplayname);
    };

    Auth.prototype.api = function() {
      restify.use(passport.initialize());
      restify.use(passport.session());
      passport.serializeUser(function(user, done) {
        return done(null, user.id);
      });
      return passport.deserializeUser(function(id, done) {
        return inject.one('odo user by id')(id, done);
      });
    };

    Auth.prototype.projection = function() {
      hub.every('assign email address {email} to user {id}', (function(_this) {
        return function(m, cb) {
          return _this.db().hset("" + config.odo.domain + ":useremail", m.email, m.id, function() {
            return cb();
          });
        };
      })(this));
      return hub.every('create verify email token for email {email} of user {id}', (function(_this) {
        return function(m, cb) {
          var key;
          key = "" + config.odo.domain + ":emailverificationtoken:" + m.email + ":" + m.token;
          return _this.db().multi().set(key, m.id).expire(key, 60 * 60 * 24).exec(function(err, replies) {
            if (err != null) {
              throw err;
            }
            return cb();
          });
        };
      })(this));
    };

    Auth.prototype.signout = function(req, res) {
      req.logout();
      if (config.odo.auth.signout != null) {
        return res.redirect(config.odo.auth.signout);
      }
      return res.redirect('/');
    };

    Auth.prototype.user = function(req, res) {
      return res.send(req.user);
    };

    Auth.prototype.forgot = function(req, res) {
      if (req.query.email == null) {
        return res.send(400, 'Email address required');
      }
      return this.db().hget("" + config.odo.domain + ":useremail", req.query.email, (function(_this) {
        return function(err, userid) {
          if (err != null) {
            throw err;
          }
          if (userid == null) {
            res.send({
              account: false,
              message: 'No account found for this email address'
            });
            return;
          }
          return inject.one('odo user by id')(userid, function(err, user) {
            if (err != null) {
              return res.send(500, 'Couldn\'t find user');
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
        };
      })(this));
    };

    Auth.prototype.verifyemail = function(req, res) {
      var token;
      if (req.user == null) {
        return res.send(403, 'authentication required');
      }
      if (req.body.email == null) {
        return res.send(400, 'Email address required');
      }
      token = uuid.v4();
      hub.emit('create verify email token for email {email} of user {id}', {
        id: req.user.id,
        email: req.body.email,
        token: token
      });
      return res.send('Done');
    };

    Auth.prototype.checkemailverificationtoken = function(req, res) {
      var key;
      if (req.user == null) {
        return res.send(403, 'Authentication required');
      }
      if (req.query.email == null) {
        return res.send(400, 'Email address required');
      }
      if (req.query.token == null) {
        return res.send(400, 'Token required');
      }
      key = "" + config.odo.domain + ":emailverificationtoken:" + req.query.email + ":" + req.query.token;
      return this.db().get(key, (function(_this) {
        return function(err, userid) {
          if (err != null) {
            throw err;
          }
          if (userid == null) {
            return res.send({
              isValid: false,
              message: 'Token not valid'
            });
          }
          if (req.user.id !== userid) {
            return res.send(403, 'authentication required');
          }
          return res.send({
            isValid: true,
            message: 'Token valid'
          });
        };
      })(this));
    };

    Auth.prototype.emailverified = function(req, res) {
      var key;
      if (req.user == null) {
        return res.send(403, 'authentication required');
      }
      if (req.body.email == null) {
        return res.send(400, 'Email address required');
      }
      if (req.body.token == null) {
        return res.send(400, 'Token required');
      }
      key = "" + config.odo.domain + ":emailverificationtoken:" + req.body.email + ":" + req.body.token;
      return this.db().get(key, (function(_this) {
        return function(err, userid) {
          if (err != null) {
            throw err;
          }
          if (userid == null) {
            return res.send(400, 'Token not valid');
          }
          if (req.user.id !== userid) {
            return res.send(403, 'authentication required');
          }
          hub.emit('assign email address {email} to user {id}', {
            id: userid,
            email: req.body.email,
            oldemail: req.user.email,
            token: req.body.token
          });
          return _this.db().del(key, function(err, reply) {
            if (err != null) {
              throw err;
            }
            return res.send('Done');
          });
        };
      })(this));
    };

    Auth.prototype.assigndisplayname = function(req, res) {
      var p;
      if (req.body.displayName == null) {
        return res.send(400, 'Display name required');
      }
      if (req.body.id == null) {
        return res.send(400, 'Id required');
      }
      p = {
        id: req.body.id,
        displayName: req.body.displayName
      };
      return hub.emit('assign displayName {displayName} to user {id}', p, function() {
        return res.send('Ok');
      });
    };

    return Auth;

  })();
});

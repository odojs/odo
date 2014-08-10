// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['passport', 'passport-local', 'node-uuid', 'redis', 'bcryptjs', 'odo/config', 'odo/hub', 'odo/express', 'odo/inject'], function(passport, passportlocal, uuid, redis, bcrypt, config, hub, express, inject) {
    var LocalAuthentication;
    return LocalAuthentication = (function() {
      function LocalAuthentication() {
        this.remove = __bind(this.remove, this);
        this.assignpassword = __bind(this.assignpassword, this);
        this.assignusername = __bind(this.assignusername, this);
        this.signup = __bind(this.signup, this);
        this.reset = __bind(this.reset, this);
        this.generateresettoken = __bind(this.generateresettoken, this);
        this.getresettoken = __bind(this.getresettoken, this);
        this.usernameavailability = __bind(this.usernameavailability, this);
        this.emailavailability = __bind(this.emailavailability, this);
        this.test = __bind(this.test, this);
        this.signin = __bind(this.signin, this);
        this.auth = __bind(this.auth, this);
        this.projection = __bind(this.projection, this);
        this.updateemail = __bind(this.updateemail, this);
        this.web = __bind(this.web, this);
        this.db = __bind(this.db, this);
      }

      LocalAuthentication.prototype.db = function() {
        if (this._db != null) {
          return this._db;
        }
        return this._db = redis.createClient(config.redis.port, config.redis.host);
      };

      LocalAuthentication.prototype.web = function() {
        passport.use(new passportlocal.Strategy(this.signin));
        express.post('/odo/auth/local', this.auth);
        express.get('/odo/auth/local/test', this.test);
        express.get('/odo/auth/local/usernameavailability', this.usernameavailability);
        express.get('/odo/auth/local/emailavailability', this.emailavailability);
        express.get('/odo/auth/local/resettoken', this.getresettoken);
        express.post('/odo/auth/local/reset', this.reset);
        express.post('/odo/auth/local/signup', this.signup);
        express.post('/odo/auth/local/assignusername', this.assignusername);
        express.post('/odo/auth/local/assignpassword', this.assignpassword);
        express.post('/odo/auth/local/remove', this.remove);
        return express.post('/odo/auth/local/resettoken', (function(_this) {
          return function(req, res) {
            if (req.body.email == null) {
              return res.send(400, 'Email address required');
            }
            return _this.generateresettoken(req.body.email, function(err, result) {
              if (err != null) {
                throw err;
              }
              return res.send(result);
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.updateemail = function(m, cb) {
        return this.db().hset("" + config.odo.domain + ":localemails", m.email, m.id, (function(_this) {
          return function() {
            if (m.oldemail != null) {
              return _this.db().hdel("" + config.odo.domain + ":localemails", m.oldemail, function() {
                return cb();
              });
            } else {
              return cb();
            }
          };
        })(this));
      };

      LocalAuthentication.prototype.projection = function() {
        hub.every('create local signin for user {id}', (function(_this) {
          return function(m, cb) {
            return _this.db().hset("" + config.odo.domain + ":localusers", m.profile.username, m.id, function() {
              return cb();
            });
          };
        })(this));
        hub.every('create local signin for user {id}', (function(_this) {
          return function(m, cb) {
            return _this.db().hset("" + config.odo.domain + ":localemails", m.profile.email, m.id, function() {
              return cb();
            });
          };
        })(this));
        hub.every('create invitation {id}', this.updateemail);
        hub.every('create verify email token for email {email} of user {id}', this.updateemail);
        hub.every('assign email address {email} to user {id}', this.updateemail);
        hub.every('assign username {username} to user {id}', (function(_this) {
          return function(m, cb) {
            return _this.get(m.username, function(err, userid) {
              if (err != null) {
                throw err;
              }
              if (userid == null) {
                return cb();
              }
              return _this.db().hset("" + config.odo.domain + ":localusers", m.username, m.id, function() {
                return cb();
              });
            });
          };
        })(this));
        hub.every('remove local signin from user {id}', (function(_this) {
          return function(m, cb) {
            return _this.db().hdel("" + config.odo.domain + ":localusers", m.profile.username, function() {
              return cb();
            });
          };
        })(this));
        return hub.every('create password reset token for user {id}', (function(_this) {
          return function(m, cb) {
            var key;
            key = "" + config.odo.domain + ":passwordresettoken:" + m.token;
            return _this.db().multi().set(key, m.id).expire(key, 60 * 60 * 24).exec(function(err, replies) {
              if (err != null) {
                throw err;
              }
              return cb();
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.auth = function(req, res, next) {
        return passport.authenticate('local', function(err, user, info) {
          var _ref, _ref1;
          if (err != null) {
            return next(err);
          }
          if (!user) {
            if (((_ref = config.odo.auth) != null ? (_ref1 = _ref.local) != null ? _ref1.failureRedirect : void 0 : void 0) != null) {
              return res.redirect(config.odo.auth.local.failureRedirect);
            }
            return res.redirect('/#auth/local/failure');
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
            if (((_ref3 = config.odo.auth) != null ? (_ref4 = _ref3.local) != null ? _ref4.successRedirect : void 0 : void 0) != null) {
              return res.redirect(config.odo.auth.local.successRedirect);
            }
            return res.redirect('/#auth/local/success');
          });
        })(req, res, next);
      };

      LocalAuthentication.prototype.signin = function(username, password, done) {
        var userid;
        userid = null;
        return this.get(username, (function(_this) {
          return function(err, userid) {
            if (err != null) {
              throw err;
            }
            if (userid == null) {
              return done(null, false, {
                message: 'Incorrect username or password.',
                userid: null
              });
            }
            return inject.one('odo user by id')(userid, function(err, user) {
              if (err != null) {
                throw err;
              }
              if (!bcrypt.compareSync(password, user.local.profile.password)) {
                return done(null, false, {
                  message: 'Incorrect username or password.',
                  userid: userid
                });
              }
              return done(null, user);
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.test = function(req, res) {
        if (req.query.username == null) {
          return res.send({
            isValid: false,
            message: 'Username required'
          });
        }
        if (req.query.password == null) {
          return res.send({
            isValid: false,
            message: 'Password required'
          });
        }
        return this.get(req.query.username, (function(_this) {
          return function(err, userid) {
            var password;
            if (err != null) {
              throw err;
            }
            if (userid == null) {
              return res.send({
                isValid: false,
                message: 'Incorrect username or password'
              });
            }
            password = req.query.password;
            return inject.one('odo user by id')(userid, function(err, user) {
              if (err != null) {
                throw err;
              }
              if (!bcrypt.compareSync(password, user.local.profile.password)) {
                return res.send({
                  isValid: false,
                  message: 'Incorrect username or password'
                });
              }
              return res.send({
                isValid: true,
                message: 'Correct username and password'
              });
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.emailavailability = function(req, res) {
        if (req.query.email == null) {
          return res.send({
            isAvailable: false,
            message: 'Required'
          });
        }
        return this.db().hget("" + config.odo.domain + ":localemails", req.query.email, (function(_this) {
          return function(err, userid) {
            if (err != null) {
              throw err;
            }
            if (userid == null) {
              return res.send({
                isAvailable: true,
                message: 'Available'
              });
            }
            return res.send({
              isAvailable: false,
              message: 'Taken'
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.usernameavailability = function(req, res) {
        if (req.query.username == null) {
          return res.send({
            isAvailable: false,
            message: 'Required'
          });
        }
        return this.get(req.query.username, (function(_this) {
          return function(err, userid) {
            if (err != null) {
              throw err;
            }
            if (userid == null) {
              return res.send({
                isAvailable: true,
                message: 'Available'
              });
            }
            return res.send({
              isAvailable: false,
              message: 'Taken'
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.getresettoken = function(req, res) {
        if (req.query.token == null) {
          return res.send(400, 'Token required');
        }
        return this.db().get("" + config.odo.domain + ":passwordresettoken:" + req.query.token, (function(_this) {
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
            return inject.one('odo user by id')(userid, function(err, user) {
              if (err != null) {
                throw err;
              }
              if (userid == null) {
                return res.send({
                  isValid: false,
                  message: 'Token not valid'
                });
              }
              return res.send({
                isValid: true,
                username: user.username,
                message: 'Token valid'
              });
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.generateresettoken = function(email, cb) {
        return this.db().hget("" + config.odo.domain + ":useremail", email, (function(_this) {
          return function(err, userid) {
            var result;
            if (err != null) {
              return cb(err, null);
            }
            if (userid == null) {
              return cb('Incorrect email address', null);
            }
            result = {
              id: userid,
              token: uuid.v4()
            };
            return hub.emit('create password reset token for user {id}', result, function() {
              return hub.emit('send password reset token to user {id}', result, function() {
                return cb(null, result);
              });
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.reset = function(req, res) {
        var key;
        if (req.body.token == null) {
          return res.send(400, 'Token required');
        }
        if (req.body.password == null) {
          return res.send(400, 'Password required');
        }
        if (req.body.password.length < 8) {
          return res.send(400, 'Password needs to be at least eight letters long');
        }
        key = "" + config.odo.domain + ":passwordresettoken:" + req.body.token;
        return this.db().get(key, (function(_this) {
          return function(err, userid) {
            if (err != null) {
              throw err;
            }
            if (userid == null) {
              return res.send(400, 'Token not valid');
            }
            hub.emit('set password of user {id}', {
              id: userid,
              password: bcrypt.hashSync(req.body.password, 12)
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

      LocalAuthentication.prototype.signup = function(req, res) {
        var profile, userid;
        if (req.body.displayName == null) {
          return res.send(400, 'Full name required');
        }
        if (req.body.username == null) {
          return res.send(400, 'Username required');
        }
        if (req.body.password == null) {
          return res.send(400, 'Password required');
        }
        if (req.body.password.length < 8) {
          return res.send(400, 'Password needs to be at least eight letters long');
        }
        if (req.body.password !== req.body.passwordconfirm) {
          return res.send(400, 'Passwords must match');
        }
        userid = null;
        profile = req.body;
        profile.password = bcrypt.hashSync(profile.password, 12);
        delete req.body.passwordconfirm;
        if (req.user != null) {
          console.log('user already exists, creating local signin');
          userid = req.user.id;
          profile.id = req.user.id;
        } else {
          console.log('no user exists yet, creating a new id');
          userid = uuid.v4();
          profile.id = userid;
          hub.emit('start tracking user {id}', {
            id: userid,
            profile: profile
          });
        }
        hub.emit('create local signin for user {id}', {
          id: userid,
          profile: profile
        });
        hub.emit('assign username {username} to user {id}', {
          id: userid,
          username: profile.username
        });
        hub.emit('assign displayName {displayName} to user {id}', {
          id: userid,
          displayName: profile.displayName
        });
        hub.emit('set password of user {id}', {
          id: userid,
          password: profile.password
        });
        return inject.one('odo user by id')(userid, (function(_this) {
          return function(err, user) {
            if (err != null) {
              return res.send(500, 'Couldn\'t find user');
            }
            return req.login(user, function(err) {
              if (err != null) {
                return res.send(500, 'Couldn\'t login user');
              }
              return res.redirect('/');
            });
          };
        })(this));
      };

      LocalAuthentication.prototype.assignusername = function(req, res) {
        if (req.body.username == null) {
          return res.send(400, 'Username required');
        }
        if (req.body.id == null) {
          return res.send(400, 'Id required');
        }
        return hub.emit('assign username {username} to user {id}', {
          id: req.body.id,
          username: req.body.username
        });
      };

      LocalAuthentication.prototype.assignpassword = function(req, res) {
        if (req.body.password == null) {
          return res.send(400, 'Password required');
        }
        if (req.body.id == null) {
          return res.send(400, 'Id required');
        }
        return hub.emit('set password of user {id}', {
          id: req.body.id,
          password: bcrypt.hashSync(req.body.password, 12)
        });
      };

      LocalAuthentication.prototype.remove = function(req, res) {
        if (req.body.id == null) {
          return res.send(400, 'Id required');
        }
        if (req.body.profile == null) {
          return res.send(400, 'Profile required');
        }
        return hub.emit('remove local signin from user {id}', {
          id: req.body.id,
          profile: req.body.profile
        });
      };

      LocalAuthentication.prototype.get = function(username, callback) {
        return this.db().hget("" + config.odo.domain + ":localusers", username, (function(_this) {
          return function(err, data) {
            if (err != null) {
              return callback(err);
            }
            return callback(null, data);
          };
        })(this));
      };

      return LocalAuthentication;

    })();
  });

}).call(this);

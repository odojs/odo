// Generated by CoffeeScript 1.8.0
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['odo/config', 'odo/recorder'], function(config, Recorder) {
  var Express;
  Express = (function(_super) {
    __extends(Express, _super);

    Express.prototype.configMethods = ['route', 'use'];

    Express.prototype.appMethods = ['get', 'post', 'put', 'delete', 'engine', 'set'];

    function Express() {
      this.web = __bind(this.web, this);
      var method, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.configMethods;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        this[method] = this._record(method);
      }
      _ref1 = this.appMethods;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        method = _ref1[_j];
        this[method] = this._record(method);
      }
      Express.__super__.constructor.call(this);
    }

    Express.prototype.modulepath = function(uri) {
      var items;
      items = uri.split('/');
      items.pop();
      return items.join('/');
    };

    Express.prototype.web = function() {
      var RedisStore, alloweddomains, bodyParser, express, http, key, port, session, sessionConfig, sessionOptions, value, _ref, _ref1, _ref2;
      http = require('http');
      express = require('express');
      this.app = express();
      _ref = config.express;
      for (key in _ref) {
        value = _ref[key];
        this.app.set(key, value);
      }
      this.app.use(require('compression')());
      bodyParser = require('body-parser');
      this.app.use(bodyParser.urlencoded({
        extended: true
      }));
      this.app.use(bodyParser.json());
      if (this.app.get('upload directory') != null) {
        this.app.use(require('multer')({
          dest: this.app.get('upload directory')
        }));
      }
      this.app.use(require('method-override')());
      this.app.use(require('cookie-parser')(this.app.get('cookie secret')));
      if ((this.app.get('use redis sessions') != null) && this.app.get('use redis sessions')) {
        session = require('express-session');
        RedisStore = require('connect-redis')(session);
        sessionOptions = {};
        if (config.redis.socket != null) {
          sessionOptions.store = new RedisStore({
            socket: config.redis.socket,
            prefix: "" + config.odo.domain + ":sess:"
          });
        } else {
          sessionOptions.store = new RedisStore({
            host: config.redis.host,
            port: config.redis.port,
            prefix: "" + config.odo.domain + ":sess:"
          });
        }
        sessionConfig = (_ref1 = config.express) != null ? _ref1.session : void 0;
        if (sessionConfig != null) {
          if (sessionConfig.rolling != null) {
            sessionOptions.rolling = sessionConfig.rolling;
          }
          if (sessionConfig.cookie != null) {
            sessionOptions.cookie = {};
            _ref2 = sessionConfig.cookie;
            for (key in _ref2) {
              value = _ref2[key];
              sessionOptions.cookie[key] = value;
            }
          }
        }
        this.app.use(session(sessionOptions));
      } else {
        this.app.use(require('cookie-session')({
          key: this.app.get('session key'),
          secret: this.app.get('session secret')
        }));
      }
      if (this.app.get('allowed cross domains') != null) {
        alloweddomains = this.app.get('allowed cross domains').split(' ');
        this.app.use((function(_this) {
          return function(req, res, next) {
            var referrer;
            referrer = "" + req.protocol + "://" + req.hostname;
            if (req.header('referrer') != null) {
              referrer = req.header('referrer').slice(0, -1);
            }
            if (__indexOf.call(alloweddomains, referrer) < 0) {
              return next();
            }
            res.header('Access-Control-Allow-Origin', referrer);
            res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
            res.header('Access-Control-Allow-Headers', 'Content-Type');
            return next();
          };
        })(this));
      }
      this.app.route = (function(_this) {
        return function(source, target) {
          return _this.app.use(source, express["static"](target));
        };
      })(this);
      this.play(this.app, this.configMethods);
      this.app.use(require('errorhandler')({
        dumpExceptions: true,
        showStack: true
      }));
      this.app.server = http.createServer(this.app);
      port = this.app.get('port') || process.env.PORT || 8080;
      console.log("Express is listening on port " + port + "...");
      this.app.server.listen(port);
      return this.play(this.app, this.appMethods);
    };

    return Express;

  })(Recorder);
  return new Express();
});

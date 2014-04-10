// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['http', 'express', 'odo/config', 'odo/express/configure', 'odo/express/express', 'odo/express/app'], function(http, express, config, _configure, _express, _app) {
    var Express;
    return Express = (function() {
      function Express() {
        this.start = __bind(this.start, this);
        var key, value, _ref;
        this.app = express();
        _ref = config.express;
        for (key in _ref) {
          value = _ref[key];
          this.app.set(key, value);
        }
        this.app.configure((function(_this) {
          return function() {
            _this.app.use(express.compress());
            _this.app.use(express.urlencoded());
            _this.app.use(express.json());
            if (_this.app.get('upload directory') != null) {
              _this.app.use(express.bodyParser({
                uploadDir: _this.app.get('upload directory')
              }));
            }
            _this.app.use(express.methodOverride());
            _this.app.use(express.cookieParser(_this.app.get('cookie secret')));
            _this.app.use(express.cookieSession({
              key: _this.app.get('session key'),
              secret: _this.app.get('session secret')
            }));
            _this.app.route = function(source, target) {
              return _this.app.use(source, express["static"](target));
            };
            _express.play(_this.app);
            _configure.play(_this.app);
            _this.app.use(_this.app.router);
            return _this.app.use(express.errorHandler({
              dumpExceptions: true,
              showStack: true
            }));
          };
        })(this));
      }

      Express.prototype.start = function() {
        this.app.server = http.createServer(this.app);
        this.app.server.listen(process.env.PORT || 8080);
        return _app.play(this.app);
      };

      return Express;

    })();
  });

}).call(this);

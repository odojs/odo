// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define([], function() {
    var Plugins;
    return Plugins = (function() {
      Plugins.prototype.contexts = ['web', 'domain', 'projection', 'api', 'build', 'cmd'];

      function Plugins(plugins) {
        this.context = __bind(this.context, this);
        this.run = __bind(this.run, this);
        var context, _i, _len, _ref;
        this.plugins = plugins;
        this.plugins = this.plugins.map(function(plugin) {
          if (typeof plugin === 'function') {
            return new plugin;
          }
          return plugin;
        });
        _ref = this.contexts;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          context = _ref[_i];
          this[context] = this.context(context);
        }
      }

      Plugins.prototype.run = function(name) {
        var plugin, _i, _len, _ref, _results;
        _ref = this.plugins.filter(function(p) {
          return p[name] != null;
        });
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          plugin = _ref[_i];
          _results.push(plugin[name]());
        }
        return _results;
      };

      Plugins.prototype.context = function(name) {
        return (function(_this) {
          return function() {
            return _this.run(name);
          };
        })(this);
      };

      return Plugins;

    })();
  });

}).call(this);

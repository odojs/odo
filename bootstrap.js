// Generated by CoffeeScript 1.7.1
(function() {
  var __slice = [].slice;

  define(['odo/plugins', 'odo/config'], function(Plugins, config) {
    return function(contexts) {
      config.contexts = contexts;
      return requirejs(config.systems, function() {
        var context, plugins, _i, _len;
        plugins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        plugins = new Plugins(plugins);
        if (typeof contexts === 'string') {
          contexts = [contexts];
        }
        for (_i = 0, _len = contexts.length; _i < _len; _i++) {
          context = contexts[_i];
          plugins.run(context);
        }
        return requirejs(['odo/hub'], function(hub) {
          var e, _j, _len1, _results;
          _results = [];
          for (_j = 0, _len1 = contexts.length; _j < _len1; _j++) {
            context = contexts[_j];
            if (config[context] == null) {
              continue;
            }
            _results.push((function() {
              var _k, _len2, _ref, _results1;
              _ref = config[context];
              _results1 = [];
              for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
                e = _ref[_k];
                if (e.e != null) {
                  hub.publish({
                    event: e.e,
                    payload: e.p
                  });
                }
                if (e.c != null) {
                  _results1.push(hub.send({
                    command: e.c,
                    payload: e.p
                  }));
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            })());
          }
          return _results;
        });
      });
    };
  });

}).call(this);

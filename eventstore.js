// Generated by CoffeeScript 1.7.1
define(['node-uuid', 'eventstore', 'eventstore.redis', 'odo/hub', 'odo/config'], function(uuid, eventstore, storage, hub, config) {
  var es, getclassname;
  if (['projection', 'domain'].filter(function(n) {
    return config.contexts.indexOf(n) !== -1;
  }).length === 0) {
    return;
  }
  es = eventstore.createStore({
    host: config.redis.host,
    port: config.redis.port
  });
  es.configure(function() {
    es.use({
      publish: hub.publish
    });
    return es.use(storage.createStorage());
  }).start();
  getclassname = function(constructor) {
    return constructor.toString().split('(')[0].split(' ')[1];
  };
  return {
    extend: function(aggregate) {
      var bind, extensions, method, name, _results;
      aggregate._uncommitted = [];
      extensions = {
        loadFromHistory: function(history) {
          var event, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = history.length; _i < _len; _i++) {
            event = history[_i];
            event.payload.fromHistory = true;
            _results.push(this.apply(event.payload));
          }
          return _results;
        },
        apply: function(event) {
          if (this["_" + event.event] != null) {
            this["_" + event.event](event);
          }
          if (!event.fromHistory) {
            return this._uncommitted.push(event);
          }
        },
        "new": function(event, payload) {
          return this.apply({
            id: uuid.v4(),
            time: new Date(),
            payload: payload,
            event: event
          });
        },
        applyHistoryThenCommand: function(command, callback) {
          return es.getEventStream(this.id, (function(_this) {
            return function(err, stream) {
              var classname, identifier;
              identifier = aggregate.id.split('-').pop();
              if (_this.constructor) {
                classname = getclassname(_this.constructor);
                identifier = "" + classname + " " + identifier;
              }
              _this.loadFromHistory(stream.events);
              return _this[command.command](command.payload, function(err) {
                var event, _i, _len, _ref;
                if (err) {
                  console.log(err);
                  if (callback != null) {
                    callback(err);
                  }
                  return;
                }
                _ref = _this._uncommitted;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  event = _ref[_i];
                  stream.addEvent(event);
                }
                stream.commit();
                _this._uncommitted = [];
                if (callback != null) {
                  return callback(null);
                }
              });
            };
          })(this));
        }
      };
      bind = function(method) {
        return function() {
          return method.apply(aggregate, arguments);
        };
      };
      _results = [];
      for (name in extensions) {
        method = extensions[name];
        _results.push(aggregate[name] = bind(method));
      }
      return _results;
    }
  };
});

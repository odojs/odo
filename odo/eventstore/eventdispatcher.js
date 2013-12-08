// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['odo/eventstore/hub', 'odo/injectinto', 'service/itemevents'], function(hub, inject, itemlistener) {
    return {
      start: function() {
        var addBinding, bindings;
        bindings = {};
        addBinding = function(binding) {
          var method, name, _results;
          _results = [];
          for (name in binding) {
            method = binding[name];
            if (bindings[name] == null) {
              bindings[name] = [];
            }
            _results.push(bindings[name].push(method));
          }
          return _results;
        };
        addBinding(itemlistener);
        return hub.on('events', function(data) {
          var listener, _i, _len, _ref, _results;
          console.log(data);
          console.log("eventDenormalizer -- denormalize event " + data.event);
          _ref = inject.many("eventlisteners:" + data.event);
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            listener = _ref[_i];
            _results.push(listener(data));
          }
          return _results;
        });
      }
    };
  });

}).call(this);
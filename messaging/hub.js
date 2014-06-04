// Generated by CoffeeScript 1.7.1
(function() {
  define(['redis', 'odo/config', 'odo/messaging/sequencer'], function(redis, config, Sequencer) {
    var commandreceiver, commandsender, ensequence, eventlistener, eventpublisher, eventsequencer, getfilename, handlers, listeners, result, subscriptions;
    commandsender = redis.createClient(config.redis.port, config.redis.host);
    eventpublisher = redis.createClient(config.redis.port, config.redis.host);
    subscriptions = [];
    listeners = {};
    handlers = {};
    getfilename = function() {
      return new Error().stack.split('\n')[3].split(')')[0].split('/').pop().split(':').splice(0, 2).join(':');
    };
    result = {
      print: function() {
        var event, list, listener, _results;
        _results = [];
        for (event in listeners) {
          list = listeners[event];
          _results.push((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = list.length; _i < _len; _i++) {
              listener = list[_i];
              console.log("" + event + " ->");
              _results1.push(console.log(listener.toString()));
            }
            return _results1;
          })());
        }
        return _results;
      },
      send: function(command) {
        var filename;
        filename = getfilename();
        console.log("" + filename + " sending command " + command.command);
        console.log(JSON.stringify(command.payload, null, 2));
        command = JSON.stringify(command, null, 4);
        return commandsender.publish("" + config.odo.domain + ".commands", command);
      },
      handle: function(command, callback) {
        var filename;
        filename = getfilename();
        console.log("" + filename + " subscribing handler for " + command);
        if (handlers[command] != null) {
          console.log("Error, handler already set for " + command);
          return;
        }
        return handlers[command] = {
          filename: filename,
          callback: callback
        };
      },
      publish: function(event) {
        var filename;
        filename = getfilename();
        console.log("" + filename + " publishing event " + event.event);
        console.log(JSON.stringify(event.payload, null, 2));
        return eventpublisher.publish("" + config.odo.domain + ".events", JSON.stringify(event, null, 4));
      },
      receive: function(event, callback) {
        var filename;
        filename = getfilename();
        console.log("" + filename + " listening to " + event);
        if (listeners[event] == null) {
          listeners[event] = [];
        }
        return listeners[event].push({
          filename: filename,
          callback: callback
        });
      },
      eventstream: function(callback) {
        console.log("Subscribing to the eventstream");
        return subscriptions.push(callback);
      }
    };
    commandreceiver = redis.createClient(config.redis.port, config.redis.host);
    commandreceiver.on('message', function(channel, command) {
      var binding;
      command = JSON.parse(command);
      if (handlers[command.command] != null) {
        binding = handlers[command.command];
        console.log("" + binding.filename + " handling command " + command.command);
        console.log(JSON.stringify(command.payload, null, 2));
        return binding.callback(command);
      }
    });
    console.log("Subscribing to " + config.odo.domain + ".commands redis channel for commands");
    commandreceiver.subscribe("" + config.odo.domain + ".commands");
    eventlistener = redis.createClient(config.redis.port, config.redis.host);
    eventsequencer = new Sequencer();
    ensequence = function(event, listener) {
      return eventsequencer.push(event, function(cb) {
        return listener(event, cb);
      });
    };
    eventlistener.on('message', function(channel, event) {
      var binding, listener, subscriber, _i, _j, _len, _len1, _ref, _results;
      event = JSON.parse(event);
      for (_i = 0, _len = subscriptions.length; _i < _len; _i++) {
        subscriber = subscriptions[_i];
        ensequence(event, subscriber);
      }
      if (listeners[event.event] != null) {
        _ref = listeners[event.event];
        _results = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          listener = _ref[_j];
          binding = listener;
          console.log("" + binding.filename + " hearing event " + event.event);
          console.log(JSON.stringify(event.payload, null, 2));
          _results.push(ensequence(event, binding.callback));
        }
        return _results;
      }
    });
    console.log("Subscribing to " + config.odo.domain + ".events redis channel for events");
    eventlistener.subscribe("" + config.odo.domain + ".events");
    return result;
  });

}).call(this);

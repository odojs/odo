// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['redis', 'eventstore', 'eventstore.redis', 'itemcommands'], function(redis, eventstore, storage, itemcommands) {
    return {
      start: function() {
        var addBinding, bindings, es, subscriber;
        bindings = {};
        addBinding = function(binding) {
          var method, name, _results;
          _results = [];
          for (name in binding) {
            method = binding[name];
            _results.push(bindings[name] = method);
          }
          return _results;
        };
        addBinding(itemcommands);
        es = eventstore.createStore();
        es.configure(function() {
          var publisher;
          publisher = redis.createClient();
          es.use({
            publish: function(event) {
              console.log('Publishing event to redis:');
              console.log(event);
              return publisher.publish('events', JSON.stringify(event, null, 4));
            }
          });
          return es.use(storage.createStorage());
        }).start();
        subscriber = redis.createClient();
        subscriber.on('message', function(channel, message) {
          var command;
          command = JSON.parse(message);
          console.log('Received command from redis:');
          console.log(command);
          if (bindings[command.command] == null) {
            console.log("Could not find a command handler for " + command.command + ", this is an error!");
            return;
          }
          return bindings[command.command](command.payload, {
            applyHistoryThenCommand: function(aggregate, callback) {
              console.log("Load history for id= " + aggregate.id);
              return es.getEventStream(aggregate.id, function(err, stream) {
                console.log("Apply existing events " + stream.events.length);
                aggregate.loadFromHistory(stream.events);
                console.log("Apply command " + command.command + " to aggregate");
                return aggregate[command.command](command.payload, function(err, uncommitted) {
                  if (err) {
                    return console.log(err);
                  } else {
                    stream.addEvent(uncommitted[0]);
                    return stream.commit();
                  }
                });
              });
            }
          });
        });
        return subscriber.subscribe('commands');
      }
    };
  });

}).call(this);

// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['eventstore', 'eventstore.redis'], function(eventstore, storage) {
    var es;
    es = eventstore.createStore();
    return storage.createStorage(function(err, store) {
      return es.configure(function() {
        return es.use(store);
      });
    });
  });

}).call(this);
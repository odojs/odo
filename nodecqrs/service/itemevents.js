// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['nodecqrs/storage'], function(store) {
    return {
      itemCreated: function(evt) {
        return store.save({
          id: evt.payload.id,
          text: evt.payload.text
        }, function(err) {});
      },
      itemChanged: function(evt) {
        return store.load(evt.payload.id, function(err, item) {
          item.text = evt.payload.text;
          return store.save(item, function(err) {});
        });
      },
      itemDeleted: function(evt) {
        return store.del(evt.payload.id, function(err) {});
      }
    };
  });

}).call(this);

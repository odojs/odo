// Generated by CoffeeScript 1.6.3
(function() {
  define(['redis', 'async'], function(redis, async) {
    var db, store;
    db = redis.createClient();
    store = {
      load: function(id, callback) {
        return db.get("readmodel:article:" + id, function(err, data) {
          if (err) {
            callback(err);
          }
          return callback(null, JSON.parse(data));
        });
      },
      loadAll: function(callback) {
        return db.smembers('readmodel:articles', function(err, keys) {
          if (err) {
            callback(err);
          }
          return async.map(keys, store.load, function(err, items) {
            if (err) {
              callback(err);
            }
            return callback(null, items);
          });
        });
      },
      save: function(item, callback) {
        return db.sismember('readmodel:articles', item.id, function(err, exists) {
          if (err) {
            callback(err);
          }
          if (!exists) {
            db.sadd('readmodel:articles', item.id);
          }
          db.set("readmodel:article:" + item.id, JSON.stringify(item));
          return callback(null);
        });
      },
      del: function(id, callback) {
        return db.srem('readmodel:articles', id, function(err) {
          if (err) {
            callback(err);
          }
          return db.del(id, function(err) {
            if (err) {
              callback(err);
            }
            return callback(null);
          });
        });
      }
    };
    return store;
  });

}).call(this);

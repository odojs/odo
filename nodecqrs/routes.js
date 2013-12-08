// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['service/storage'], function(store) {
    return function(app) {
      app.get('/', function(req, res) {
        return res.render('index');
      });
      return app.get('/allItems.json', function(req, res) {
        return store.loadAll(function(err, items) {
          if (err) {
            res.json({});
          }
          return res.json(items);
        });
      });
    };
  });

}).call(this);

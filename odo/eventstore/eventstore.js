// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['module', 'path', 'express', 'odo/eventstore'], function(module, path, express, eventstore) {
    return {
      configure: function(app) {
        app.es = eventstore;
        return app.use('/odo', express["static"](path.dirname(module.uri) + '/public'));
      },
      init: function(app) {
        return app.get('/eventstore/test', function(req, res) {
          console.log(app.es);
          return res.send('totally works');
        });
      }
    };
  });

}).call(this);

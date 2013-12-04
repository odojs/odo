// Generated by IcedCoffeeScript 1.6.3-g
(function() {


  define(['jquery'], function($) {
    var cache,
      _this = this;
    cache = null;
    return {
      getUser: function(done) {
        if (_this.cache != null) {
          done(null, _this.cache);
        }
        return $.get('/auth/user').then(function(data) {
          this.cache = data;
          return done(null, data);
        }).fail(function(xhr, err) {
          return done(err);
        });
      }
    };
  });

}).call(this);

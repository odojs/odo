// Generated by CoffeeScript 1.6.3
(function() {
  define(['jquery'], function($) {
    var _this = this;
    return {
      getUsernameAvailability: function(username) {
        return $.get('/odo/auth/local/usernameavailability', {
          username: username
        });
      }
    };
  });

}).call(this);

// Generated by CoffeeScript 1.7.1
(function() {
  define([], function() {
    return function(wait, func) {
      var apply, args;
      args = Array.prototype.slice.call(arguments, 2);
      apply = function() {
        return func.apply(null, args);
      };
      return setTimeout(apply, wait);
    };
  });

}).call(this);
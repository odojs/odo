// Generated by CoffeeScript 1.7.1
(function() {
  define(['module', 'odo/express'], function(module, express) {
    var Bower;
    return Bower = (function() {
      function Bower() {}

      Bower.prototype.web = function() {
        return express.route('/bower_components', express.modulepath(module.uri) + '/../../bower_components');
      };

      return Bower;

    })();
  });

}).call(this);

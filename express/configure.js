// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['odo/infra/recorder'], function(Recorder) {
    var Configure;
    Configure = (function(_super) {
      __extends(Configure, _super);

      function Configure() {
        Configure.__super__.constructor.apply(this, arguments);
      }

      Configure.prototype.modulepath = function(uri) {
        var items;
        items = uri.split('/');
        items.pop();
        return items.join('/');
      };

      return Configure;

    })(Recorder);
    return new Configure(['route']);
  });

}).call(this);
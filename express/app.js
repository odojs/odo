// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['odo/infra/recorder'], function(Recorder) {
    var Init;
    Init = (function(_super) {
      __extends(Init, _super);

      function Init() {
        Init.__super__.constructor.apply(this, arguments);
      }

      return Init;

    })(Recorder);
    return new Init(['get', 'post', 'put', 'delete']);
  });

}).call(this);

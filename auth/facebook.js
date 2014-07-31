// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['passport', 'passport-facebook', 'odo/config', 'odo/auth/provider'], function(passport, passportfacebook, config, ProviderAuthentication) {
    var FacebookAuthentication;
    return FacebookAuthentication = (function(_super) {
      __extends(FacebookAuthentication, _super);

      function FacebookAuthentication() {
        this.web = __bind(this.web, this);
        this.provider = 'facebook';
      }

      FacebookAuthentication.prototype.web = function() {
        passport.use(new passportfacebook.Strategy({
          clientID: config.passport.facebook['app id'],
          clientSecret: config.passport.facebook['app secret'],
          callbackURL: config.passport.facebook['host'] + '/odo/auth/facebook/callback',
          passReqToCallback: true
        }, this.signin));
        return FacebookAuthentication.__super__.web.call(this);
      };

      return FacebookAuthentication;

    })(ProviderAuthentication);
  });

}).call(this);

// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['passport', 'passport-google', 'odo/config', 'odo/auth/provider'], function(passport, passportgoogle, config, ProviderAuthentication) {
    var GoogleAuthentication;
    return GoogleAuthentication = (function(_super) {
      __extends(GoogleAuthentication, _super);

      function GoogleAuthentication() {
        this.web = __bind(this.web, this);
        this.provider = 'google';
      }

      GoogleAuthentication.prototype.web = function() {
        passport.use(new passportgoogle.Strategy({
          realm: config.passport.google['realm'],
          returnURL: config.passport.google['host'] + '/odo/auth/google/callback',
          passReqToCallback: true
        }, this.signin));
        return GoogleAuthentication.__super__.web.call(this);
      };

      return GoogleAuthentication;

    })(ProviderAuthentication);
  });

}).call(this);

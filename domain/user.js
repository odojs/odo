// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define([], function() {
    var User;
    return User = (function() {
      function User(id) {
        this.createLocalSigninForUser = __bind(this.createLocalSigninForUser, this);
        this.attachGoogleToUser = __bind(this.attachGoogleToUser, this);
        this.attachFacebookToUser = __bind(this.attachFacebookToUser, this);
        this.attachTwitterToUser = __bind(this.attachTwitterToUser, this);
        this.startTrackingUser = __bind(this.startTrackingUser, this);
        this.id = id;
      }

      User.prototype.startTrackingUser = function(command, callback) {
        this["new"]('userTrackingStarted', {
          id: this.id,
          profile: command.profile
        });
        return callback(null);
      };

      User.prototype.attachTwitterToUser = function(command, callback) {
        this["new"]('userTwitterAttached', {
          id: this.id,
          profile: command.profile
        });
        return callback(null);
      };

      User.prototype.attachFacebookToUser = function(command, callback) {
        this["new"]('userFacebookAttached', {
          id: this.id,
          profile: command.profile
        });
        return callback(null);
      };

      User.prototype.attachGoogleToUser = function(command, callback) {
        this["new"]('userGoogleAttached', {
          id: this.id,
          profile: command.profile
        });
        return callback(null);
      };

      User.prototype.createLocalSigninForUser = function(command, callback) {
        this["new"]('userHasLocalSignin', {
          id: this.id,
          profile: command.profile
        });
        return callback(null);
      };

      return User;

    })();
  });

}).call(this);
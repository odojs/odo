// Generated by CoffeeScript 1.7.1
(function() {
  define('odo/auth', ['jquery', 'q'], function($, Q) {
    var cache;
    cache = null;
    return {
      getUser: (function(_this) {
        return function() {
          var dfd;
          dfd = Q.defer();
          if (_this.cache != null) {
            dfd.resolve(_this.cache);
          } else {
            Q($.get('/odo/auth/user')).then(function(data) {
              if ((data == null) || data === '') {
                return dfd.reject();
              }
              _this.cache = data;
              return dfd.resolve(data);
            }).fail(function() {
              return dfd.reject();
            });
          }
          return dfd.promise;
        };
      })(this),
      assignUsernameToUser: (function(_this) {
        return function(id, username) {
          return Q($.post('/odo/auth/local/assignusername', {
            id: id,
            username: username
          }));
        };
      })(this),
      assignPasswordToUser: (function(_this) {
        return function(id, password) {
          return Q($.post('/odo/auth/local/assignpassword', {
            id: id,
            password: password
          }));
        };
      })(this),
      assignDisplayNameToUser: (function(_this) {
        return function(id, displayName) {
          return Q($.post('/odo/auth/assigndisplayname', {
            id: id,
            displayName: displayName
          }));
        };
      })(this),
      createVerifyEmailAddressToken: (function(_this) {
        return function(email) {
          return Q($.post('/odo/auth/verifyemail', {
            email: email
          }));
        };
      })(this),
      checkEmailVerificationToken: (function(_this) {
        return function(email, token) {
          return Q($.get('/odo/auth/checkemailverificationtoken', {
            email: email,
            token: token
          }));
        };
      })(this),
      assignEmailAddressToUserWithToken: (function(_this) {
        return function(email, token) {
          return Q($.post('/odo/auth/emailverified', {
            email: email,
            token: token
          }));
        };
      })(this),
      getUsernameAvailability: (function(_this) {
        return function(username) {
          return Q($.get('/odo/auth/local/usernameavailability', {
            username: username
          }));
        };
      })(this),
      testAuthentication: (function(_this) {
        return function(username, password) {
          return Q($.get('/odo/auth/local/test', {
            username: username,
            password: password
          }));
        };
      })(this),
      disconnectTwitterFromUser: (function(_this) {
        return function(id, profile) {
          return Q($.post('/odo/auth/twitter/disconnect', {
            id: id,
            profile: profile
          }));
        };
      })(this),
      disconnectFacebookFromUser: (function(_this) {
        return function(id, profile) {
          return Q($.post('/odo/auth/facebook/disconnect', {
            id: id,
            profile: profile
          }));
        };
      })(this),
      disconnectGoogleFromUser: (function(_this) {
        return function(id, profile) {
          return Q($.post('/odo/auth/google/disconnect', {
            id: id,
            profile: profile
          }));
        };
      })(this),
      removeLocalSigninForUser: (function(_this) {
        return function(id, profile) {
          return Q($.post('/odo/auth/local/remove', {
            id: id,
            profile: profile
          }));
        };
      })(this),
      forgotCheckEmailAddress: (function(_this) {
        return function(email) {
          return Q($.get('/odo/auth/forgot', {
            email: email
          }));
        };
      })(this),
      createPasswordResetToken: (function(_this) {
        return function(email) {
          return Q($.post('/odo/auth/local/resettoken', {
            email: email
          }));
        };
      })(this),
      checkResetToken: (function(_this) {
        return function(token) {
          return Q($.get('/odo/auth/local/resettoken', {
            token: token
          }));
        };
      })(this),
      resetPasswordWithToken: (function(_this) {
        return function(token, password) {
          return Q($.post('/odo/auth/local/reset', {
            token: token,
            password: password
          }));
        };
      })(this)
    };
  });

}).call(this);

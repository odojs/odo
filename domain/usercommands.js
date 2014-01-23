// Generated by CoffeeScript 1.6.3
(function() {
  define(['odo/eventstore', 'odo/domain/user'], function(es, User) {
    var defaultHandler;
    defaultHandler = function(command) {
      var user;
      user = new User(command.payload.id);
      es.extend(user);
      return user.applyHistoryThenCommand(command);
    };
    return {
      handle: function(hub) {
        var command, commands, _i, _len, _results;
        commands = ['startTrackingUser', 'assignEmailAddressToUser', 'createVerifyEmailAddressToken', 'assignDisplayNameToUser', 'assignUsernameToUser', 'connectTwitterToUser', 'disconnectTwitterFromUser', 'connectFacebookToUser', 'disconnectFacebookFromUser', 'connectGoogleToUser', 'disconnectGoogleFromUser', 'createLocalSigninForUser', 'assignPasswordToUser', 'createPasswordResetToken', 'removeLocalSigninForUser'];
        _results = [];
        for (_i = 0, _len = commands.length; _i < _len; _i++) {
          command = commands[_i];
          _results.push(hub.handle(command, defaultHandler));
        }
        return _results;
      }
    };
  });

}).call(this);

// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var dropbox;

  dropbox = require('dropbox');

  module.exports = {
    configure: function(app) {
      return app.inject.bind('dropbox.client', function() {
        var req;
        req = app.inject.one('req');
        if (req.user == null) return null;
        return new dropbox.Client({
          key: app.get('dropbox key'),
          secret: app.get('dropbox secret'),
          token: req.user.token,
          tokenSecret: req.user.tokenSecret,
          uid: req.user._json.uid
        });
      });
    }
  };

}).call(this);
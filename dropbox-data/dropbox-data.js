// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var dropbox, errors, strategies;

  dropbox = require('dropbox');

  errors = {
    '${dropbox.ApiError.INVALID_TOKEN}': 'Invalid token',
    '${dropbox.ApiError.NOT_FOUND}': 'Not found',
    '${dropbox.ApiError.OVER_QUOTA}': 'Over quota',
    '${dropbox.ApiError.RATE_LIMITED}': 'Rate limited',
    '${dropbox.ApiError.NETWORK_ERROR}': 'Network error',
    '${dropbox.ApiError.INVALID_PARAM}': 'Invalid parameter',
    '${dropbox.ApiError.OAUTH_ERROR}': 'OAuth Error',
    '${dropbox.ApiError.INVALID_METHOD}': 'Invalid method'
  };

  strategies = function(app) {
    return {
      'dropbox.rootfiles': function(callback) {
        var client;
        client = app.inject.one('dropbox.client')();
        if (client == null) {
          callback(null, []);
          return;
        }
        return client.readdir('/', function(error, entries) {
          if (error != null) callback(errors[error]);
          return callback(null, entries);
        });
      }
    };
  };

  module.exports = {
    configure: function(app) {
      var implementation, strategy, _ref, _results;
      _ref = strategies(app);
      _results = [];
      for (strategy in _ref) {
        implementation = _ref[strategy];
        _results.push(app.inject.bind(strategy, implementation));
      }
      return _results;
    },
    init: function(app) {
      var strategy, _, _ref, _results;
      _ref = strategies(app);
      _results = [];
      for (strategy in _ref) {
        _ = _ref[strategy];
        _results.push(app.get("/" + strategy + ".json", function(req, res) {
          return app.inject.one(strategy)(function(error, result) {
            var output;
            if (error != null) throw error;
            output = JSON.stringify(result);
            res.set({
              'Content-Type': 'application/json',
              'Content-Length': output.length
            });
            return res.send(output);
          });
        }));
      }
      return _results;
    }
  };

}).call(this);
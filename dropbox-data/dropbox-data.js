// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var dropbox, iced, path, sectionpaths, utils, _, __iced_k, __iced_k_noop;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  dropbox = require('dropbox');

  path = require('path');

  _ = require('underscore');

  sectionpaths = [];

  utils = {
    extension: '.md',
    maketitle: function(file) {
      var result;
      result = path.basename(file);
      return result = result.substr(0, result.length - utils.extension.length);
    },
    errors: {
      '${dropbox.ApiError.INVALID_TOKEN}': 'Invalid token',
      '${dropbox.ApiError.NOT_FOUND}': 'Not found',
      '${dropbox.ApiError.OVER_QUOTA}': 'Over quota',
      '${dropbox.ApiError.RATE_LIMITED}': 'Rate limited',
      '${dropbox.ApiError.NETWORK_ERROR}': 'Network error',
      '${dropbox.ApiError.INVALID_PARAM}': 'Invalid parameter',
      '${dropbox.ApiError.OAUTH_ERROR}': 'OAuth Error',
      '${dropbox.ApiError.INVALID_METHOD}': 'Invalid method'
    }
  };

  module.exports = {
    configure: function(app) {
      var pagetitles;
      app.postal.channel().subscribe('section.new', function(section) {
        return sectionpaths.push(section.path);
      });
      app.postal.channel().subscribe('section.changepath', function(message) {
        sectionpaths.remove(message.oldpath);
        return sectionpaths.push(message.newpath);
      });
      app.fetch.bind('sectionpaths', 'all', function(app, params, cb) {
        return cb(null, sectionpaths);
      });
      pagetitles = {};
      app.fetch.bind('pagetitles', 'all', function(app, params, cb) {
        var client, error, req, section, sections, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        req = app.inject.one('req');
        if (req.user == null) {
          cb(null, []);
          return;
        }
        if (pagetitles[req.user] != null) {
          cb(null, pagetitles[req.user]);
          return;
        }
        client = app.inject.one('dropbox.client')();
        if (client == null) {
          cb(null, []);
          return;
        }
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/tcoats/Source/odo/dropbox-data/dropbox-data.coffee"
          });
          app.fetch.exec('sectionpaths', 'all', app, null, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                error = arguments[0];
                return sections = arguments[1];
              };
            })(),
            lineno: 57
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (typeof error !== "undefined" && error !== null) throw error;
          sections = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = sections.length; _i < _len; _i++) {
              section = sections[_i];
              _results.push({
                path: section,
                file: path.basename(section),
                title: path.basename(section)
              });
            }
            return _results;
          })();
          (function(__iced_k) {
            var _i, _len;
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/tcoats/Source/odo/dropbox-data/dropbox-data.coffee"
            });
            for (_i = 0, _len = sections.length; _i < _len; _i++) {
              section = sections[_i];
              client.readdir(section.path, __iced_deferrals.defer({
                assign_fn: (function(__slot_1) {
                  return function() {
                    error = arguments[0];
                    return __slot_1.pages = arguments[1];
                  };
                })(section),
                lineno: 69
              }));
              if (error != null) {
                cb(utils.errors[error]);
                return;
              }
            }
            __iced_deferrals._fulfill();
          })(function() {
            var _i, _len;
            for (_i = 0, _len = sections.length; _i < _len; _i++) {
              section = sections[_i];
              section.pages = _(section.pages).filter(function(page) {
                return page.endsWith(utils.extension);
              }).map(function(page) {
                return {
                  file: page,
                  title: utils.maketitle(page)
                };
              });
            }
            pagetitles[req.user] = sections;
            return cb(null, sections);
          });
        });
      });
      app.fetch.bind('pagecontents', 'bypath', function(app, params, cb) {
        var client, data, error, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        client = app.inject.one('dropbox.client')();
        if ((client == null) || !params.path || !params.path.endsWith(utils.extension)) {
          cb(null, []);
          return;
        }
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/tcoats/Source/odo/dropbox-data/dropbox-data.coffee"
          });
          client.readFile(params.path, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                error = arguments[0];
                return data = arguments[1];
              };
            })(),
            lineno: 94
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (typeof error !== "undefined" && error !== null) {
            cb(utils.errors[error]);
            return;
          }
          return cb(null, {
            path: params.path,
            file: path.basename(params.path),
            title: utils.maketitle(params.path),
            contents: data
          });
        });
      });
      return app.fetch.bind('pagecontents', 'bysectionandpage', function(app, params, cb) {
        var client, data, error, file, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        client = app.inject.one('dropbox.client')();
        if (client == null) {
          cb(null, []);
          return;
        }
        file = path.join(params.section, params.page + utils.extension);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/tcoats/Source/odo/dropbox-data/dropbox-data.coffee"
          });
          client.readFile(file, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                error = arguments[0];
                return data = arguments[1];
              };
            })(),
            lineno: 115
          }));
          __iced_deferrals._fulfill();
        })(function() {
          if (typeof error !== "undefined" && error !== null) {
            cb(utils.errors[error]);
            return;
          }
          return cb(null, {
            path: file,
            file: path.basename(file),
            title: utils.maketitle(file),
            contents: data
          });
        });
      });
    },
    init: function(app) {
      app.postal.publish({
        topic: 'section.new',
        data: {
          title: 'Patterns and Practices',
          path: 'Knowledge/Patterns and Practices'
        }
      });
      app.postal.publish({
        topic: 'section.new',
        data: {
          title: 'Work',
          path: 'Knowledge/Work'
        }
      });
      app.postal.publish({
        topic: 'section.new',
        data: {
          title: 'Brain Dump',
          path: 'Knowledge/Brain Dump'
        }
      });
      return app.postal.publish({
        topic: 'section.new',
        data: {
          title: 'Leader of Men',
          path: 'Knowledge/Leader of Men'
        }
      });
    }
  };

}).call(this);

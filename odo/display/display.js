// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var express, iced, _, __iced_k, __iced_k_noop;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  express = require('express');

  _ = require('underscore');

  module.exports = {
    configure: function(app) {},
    init: function(app) {
      return app.get('/', function(req, res) {
        var error, sections, ___iced_passed_deferral, __iced_deferrals, __iced_k,
          _this = this;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "/Users/tcoats/Source/odo/odo/display/display.coffee"
          });
          app.fetch.exec('pagetitles', 'all', app, null, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                error = arguments[0];
                return sections = arguments[1];
              };
            })(),
            lineno: 13
          }));
          __iced_deferrals._fulfill();
        })(function() {
          return res.render({
            view: 'odo/layout',
            data: {
              title: 'Display',
              user: req.user,
              sections: sections
            },
            partials: {
              content: 'display/display'
            }
          });
        });
      });
    }
  };

}).call(this);

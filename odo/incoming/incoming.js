// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var express, _;

  express = require('express');

  _ = require('underscore');

  module.exports = {
    configure: function(app) {
      app.use('/css', express["static"](__dirname + '/css'));
      app.use('/img', express["static"](__dirname + '/img'));
      return app.use('/js', express["static"](__dirname + '/js'));
    },
    init: function(app) {
      return app.get('/%CF%86/incoming/', function(req, res) {
        console.log(req.session.test);
        return res.render({
          view: 'odo/layout',
          data: {
            title: 'Incoming',
            javascripts: ['/js/incoming.js'],
            bodyclasses: ['prompt']
          },
          partials: {
            content: 'incoming/incoming'
          }
        });
      });
    }
  };

}).call(this);
// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['module', 'path', 'handlebars', 'consolidate', 'express/lib/response', 'odo/express'], function(module, path, handlebars, cons, response, express) {
    var Handlebars;
    return Handlebars = (function() {
      function Handlebars() {
        this.web = __bind(this.web, this);
      }

      Handlebars.prototype.web = function() {
        response.render = function(options) {
          var app, content, fn, key, req, result, self, value, view, _ref, _ref1, _ref2, _ref3;
          self = this;
          req = this.req;
          app = req.app;
          view = options.view;
          if (options.result != null) {
            result = options.result;
          }
          content = {};
          _ref = options.data;
          for (key in _ref) {
            value = _ref[key];
            content[key] = value;
          }
          _ref1 = self.locals;
          for (key in _ref1) {
            value = _ref1[key];
            content[key] = value;
          }
          content.query = req.query;
          content.body = req.body;
          content.partials = {};
          _ref2 = self.locals.partials;
          for (key in _ref2) {
            value = _ref2[key];
            content.partials[key] = value;
          }
          _ref3 = options.partials;
          for (key in _ref3) {
            value = _ref3[key];
            content.partials[key] = value;
          }
          content._locals = self.locals;
          fn = result || function(err, str) {
            if (err) {
              return req.next(err);
            }
            return self.send(str);
          };
          return app.render(view, content, fn);
        };
        express.engine('html', cons.handlebars);
        express.set('view engine', 'html');
        express.set('views', path.dirname(module.uri) + '/../../');
        handlebars.registerHelper('uppercase', function(string) {
          return string.toUpperCase();
        });
        handlebars.registerHelper('lowercase', function(string) {
          return string.toLowerCase();
        });
        if (String.prototype.toTitleCase != null) {
          handlebars.registerHelper('titlecase', function(string) {
            return string.toTitleCase();
          });
        }
        handlebars.registerHelper('render', function(content, options) {
          if (content == null) {
            return '';
          }
          return new handlebars.SafeString(handlebars.compile(content)(this));
        });
        return handlebars.registerHelper('hook', function(partial, options) {
          if (this.partials[partial] == null) {
            return new handlebars.SafeString(handlebars.compile('{{render ' + partial + '}}')(this));
          }
          return new handlebars.SafeString(handlebars.compile('{{> ' + partial + '}}')(this));
        });
      };

      return Handlebars;

    })();
  });

}).call(this);

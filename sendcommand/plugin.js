// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['odo/infra/hub', 'odo/express/app'], function(hub, app) {
    var SendCommand;
    return SendCommand = (function() {
      function SendCommand() {
        this.sendcommand = __bind(this.sendcommand, this);
        this.web = __bind(this.web, this);
      }

      SendCommand.prototype.web = function() {
        return app.post('/sendcommand/:command', this.sendcommand);
      };

      SendCommand.prototype.sendcommand = function(req, res) {
        if (req.user == null) {
          res.send(403, 'authentication required');
          return;
        }
        req.body.by = req.user.id;
        hub.send({
          command: req.params.command,
          payload: req.body
        });
        return res.send('Ok');
      };

      return SendCommand;

    })();
  });

}).call(this);

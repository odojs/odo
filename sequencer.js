// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define([], function() {
    var Sequencer;
    return Sequencer = (function() {
      function Sequencer() {
        this.push = __bind(this.push, this);
        this._next = __bind(this._next, this);
      }

      Sequencer.prototype._queue = [];

      Sequencer.prototype._inprogress = false;

      Sequencer.prototype._next = function() {
        var action;
        this._inprogress = true;
        if (this._queue.length === 0) {
          this._inprogress = false;
          return;
        }
        action = this._queue.shift();
        return action(this._next);
      };

      Sequencer.prototype.push = function(action) {
        this._queue.push(action);
        if (!this._inprogress) {
          return this._next();
        }
      };

      return Sequencer;

    })();
  });

}).call(this);
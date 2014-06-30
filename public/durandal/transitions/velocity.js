// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['durandal/system', 'jquery', 'q', 'velocity'], function(system, $, Q) {
    var Velocity;
    return Velocity = (function() {
      function Velocity() {
        this.inTransition = __bind(this.inTransition, this);
        this.outTransition = __bind(this.outTransition, this);
        this.endTransition = __bind(this.endTransition, this);
        this.startTransition = __bind(this.startTransition, this);
        this.create = __bind(this.create, this);
      }

      Velocity.prototype.animations = {
        slideInRight: {
          translateX: ['0px', '2000px']
        },
        slideInLeft: {
          translateX: ['0px', '-2000px']
        },
        slideOutRight: {
          translateX: ['2000px', '0px']
        },
        slideOutLeft: {
          translateX: ['-2000px', '0px']
        }
      };

      Velocity.prototype.create = function(settings) {
        this.settings = settings;
        this.deferred = Q.defer();
        if (this.settings.scrolltop == null) {
          this.settings.scrolltop = true;
        }
        if (this.settings.child) {
          this.startTransition();
        } else {
          this.endTransition();
        }
        return this.deferred.promise;
      };

      Velocity.prototype.startTransition = function() {
        if (this.settings.activeView != null) {
          return this.outTransition();
        } else {
          return this.inTransition();
        }
      };

      Velocity.prototype.endTransition = function() {
        return this.deferred.resolve();
      };

      Velocity.prototype.outTransition = function() {
        var $previousView;
        $previousView = $(this.settings.activeView);
        $previousView.addClass('transition');
        return $previousView.velocity(this.animations[this.settings.outAnimation], 300, (function(_this) {
          return function() {
            $previousView.removeClass('transition');
            $previousView.hide();
            _this.inTransition();
            return _this.endTransition();
          };
        })(this));
      };

      Velocity.prototype.inTransition = function() {
        var $newView;
        this.settings.triggerAttach();
        $newView = $(this.settings.child);
        $newView.addClass('transition');
        $newView.velocity(this.animations[this.settings.inAnimation], 300, (function(_this) {
          return function() {
            $newView.css('-webkit-transform', '');
            $newView.css('-moz-transform', '');
            $newView.css('-ms-transform', '');
            $newView.css('transform', '');
            $newView.removeClass('transition');
            _this.endTransition();
            return $newView.find('[autofocus],.autofocus').first().focus();
          };
        })(this));
        if ((this.settings.scrolltop != null) && $(window).scrollTop() > $newView.offset().top) {
          return $('html, body').velocity({
            scrollTop: $newView.offset().top
          }, 300);
        }
      };

      return Velocity;

    })();
  });

}).call(this);
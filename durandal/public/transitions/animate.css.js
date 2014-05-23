// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['durandal/system', 'jquery', 'q'], function(system, $, Q) {
    var Animate;
    return Animate = (function() {
      function Animate() {
        this.inTransition = __bind(this.inTransition, this);
        this.outTransition = __bind(this.outTransition, this);
        this.endTransition = __bind(this.endTransition, this);
        this.startTransition = __bind(this.startTransition, this);
        this.create = __bind(this.create, this);
      }

      Animate.prototype.create = function(settings) {
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

      Animate.prototype.startTransition = function() {
        if (this.settings.activeView != null) {
          return this.outTransition();
        } else {
          return this.inTransition();
        }
      };

      Animate.prototype.endTransition = function() {
        return this.deferred.resolve();
      };

      Animate.prototype.outTransition = function() {
        var $previousView;
        $previousView = $(this.settings.activeView);
        $previousView.addClass('transition');
        $previousView.addClass('animated');
        $previousView.addClass(this.settings.outAnimation);
        return setTimeout((function(_this) {
          return function() {
            _this.inTransition();
            return _this.endTransition();
          };
        })(this), 200);
      };

      Animate.prototype.inTransition = function() {
        var $newView;
        this.settings.triggerAttach();
        $newView = $(this.settings.child);
        $newView.addClass('transition');
        $newView.addClass('animated');
        $newView.show();
        $newView.addClass(this.settings.inAnimation);
        if ((this.settings.scrolltop != null) && $(window).scrollTop() > $newView.offset().top) {
          $('html, body').animate({
            scrollTop: $newView.offset().top
          }, 300);
        }
        return setTimeout((function(_this) {
          return function() {
            $newView.removeClass(_this.settings.inAnimation);
            $newView.removeClass(_this.settings.outAnimation);
            $newView.removeClass('transition');
            $newView.removeClass('animated');
            _this.endTransition();
            return $newView.find('[autofocus],.autofocus').first().focus();
          };
        })(this), 300);
      };

      return Animate;

    })();
  });

}).call(this);

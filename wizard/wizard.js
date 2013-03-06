// Generated by IcedCoffeeScript 1.4.0b
(function() {

  (function($) {
    $.wizard = function(options, target) {
      this.options = $.extend(true, {}, $.wizard.defaults, options);
      this.target = target;
      this.init();
      return this;
    };
    $.extend($.wizard, {
      defaults: {
        delay: 400,
        width: 760,
        easing: 'swing',
        current: null,
        bind: true
      },
      prototype: {
        init: function() {
          var wizard;
          wizard = this;
          if (!this.options.width) this.options.width = this.target.innerWidth();
          this.inner = this.target.children('.inner');
          this.inner.find('.pane').hide();
          if (!this.options.current) {
            this.current = this.inner.find('.pane').first();
            this.current.show();
          }
          if (this.options.bind) {
            this.target.find('.goleft').click(function(e) {
              e.preventDefault();
              return wizard.goleft($($(this).attr('href')));
            });
            this.target.find('.goright').click(function(e) {
              e.preventDefault();
              return wizard.goright($($(this).attr('href')));
            });
            this.target.find('.shake').click(function(e) {
              e.preventDefault();
              return wizard.shake();
            });
          }
          this.inner.find('.pane').width(this.options.width);
          this.target.width(this.options.width);
          return this.inner.width(this.options.width * 2);
        },
        goleft: function(transitionTo, f) {
          var wizard;
          wizard = this;
          wizard.current.before(transitionTo);
          transitionTo.show();
          wizard.inner.css('margin-left', -1 * wizard.options.width + 'px');
          wizard.inner.animate({
            marginLeft: '+=' + wizard.options.width + 'px'
          }, {
            easing: wizard.options.easing,
            duration: wizard.options.delay,
            complete: function() {
              wizard.current.hide();
              return wizard.current = transitionTo;
            }
          });
          return this;
        },
        goright: function(transitionTo, f) {
          var wizard;
          wizard = this;
          wizard.current.after(transitionTo);
          transitionTo.show();
          wizard.inner.animate({
            marginLeft: '-=' + wizard.options.width + 'px'
          }, {
            easing: wizard.options.easing,
            duration: wizard.options.delay,
            complete: function() {
              wizard.current.hide();
              wizard.inner.css('margin-left', '0px');
              return wizard.current = transitionTo;
            }
          });
          return this;
        },
        shake: function() {
          var wizard;
          wizard = this;
          wizard.target.stop();
          wizard.target.animate({
            'margin-left': '+=10px'
          }, 50).animate({
            'margin-left': '-=20px'
          }, 100).animate({
            'margin-left': '+=20px'
          }, 100).animate({
            'margin-left': '-=20px'
          }, 100).animate({
            'margin-left': '+=10px'
          }, 50, function() {
            return wizard.target.css('margin-left', 'auto').stop();
          });
          return this;
        }
      }
    });
    return $.fn.wizard = function(options, params) {
      var result;
      result = null;
      this.each(function() {
        var wizard;
        wizard = $.data(this, 'wizard');
        if (wizard) {
          if (typeof options === 'string') {
            if (params) {
              wizard[options](params);
            } else {
              wizard[options]();
            }
          }
        } else {
          wizard = new $.wizard(options, $(this));
          $.data(this, 'wizard', wizard);
        }
        return result = wizard;
      });
      return result;
    };
  })(jQuery);

}).call(this);

// Generated by IcedCoffeeScript 1.4.0c
(function() {

  ko.bindingHandlers.slider = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
      var $element, slider, slidergroup, sliders;
      $element = $(element);
      slider = $element.data('slider');
      if (slider == null) {
        $element.append($('<div/>').addClass('handle').append($('<div />').addClass('slide')));
        slider = new Dragdealer(element, {
          vertical: true,
          disabled: $element.hasClass('slider-disabled'),
          horizontal: false,
          y: valueAccessor()()
        });
        $element.data('slider', slider);
      }
      slidergroup = $element.parents('.slider-group');
      if (!slidergroup.length) {
        slider.animationCallback = function(x, y) {
          if (valueAccessor()() === slider.value.target[1]) return;
          return valueAccessor()(slider.value.target[1]);
        };
        return;
      }
      sliders = slidergroup.data('sliders');
      if (sliders == null) sliders = [];
      sliders.push(slider);
      slidergroup.data('sliders', sliders);
      return slider.animationCallback = function(x, y) {
        var alltotal, current, others, otherstotal, split, totaldifference;
        valueAccessor()(y);
        current = this;
        others = _.filter(sliders, function(s) {
          return s !== current;
        });
        otherstotal = _.reduce(others, function(memo, s) {
          return memo + s.value.current[1];
        }, 0);
        alltotal = otherstotal + y;
        totaldifference = alltotal - 1.0;
        if (otherstotal === 0) {
          split = totaldifference / others.length;
          _.each(others, function(s) {
            var currenty;
            currenty = s.value.current[1];
            return s.setValue(x, currenty - split, true);
          });
          return;
        }
        return _.each(others, function(s) {
          var currenty, scale;
          currenty = s.value.current[1];
          scale = currenty / otherstotal;
          return s.setValue(x, currenty - scale * totaldifference, true);
        });
      };
    },
    update: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
      var slider, value;
      slider = $(element).data('slider');
      value = ko.utils.unwrapObservable(valueAccessor());
      if (slider.value.target[1] !== value) return slider.setValue(0, value);
    }
  };

}).call(this);

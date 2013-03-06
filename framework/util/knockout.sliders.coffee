# Bindings for Sliders 
# ====================
# 
# This plugin connects a decimal value to a draggable slider widget.
# This widget can be used for display and input.
# 
# Optionally, several sliders can be grouped together and edits to the amount is distributed between the sliders proportionally.

ko.bindingHandlers.slider =
  # Initialise
  # ----------
  init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->

    $element = $ element
    
    # Pull back an existing slider saved against the dom, if it exists.
    slider = $element.data 'slider'
    
    # Build a new slider if this is the first time this binding as been called.
    if !slider?
      # Create the dom elements of the slider.
      $element.append(
        $('<div/>')
          .addClass('handle')
          .append(
            $('<div />')
              .addClass('slide')))

      slider = new Dragdealer element, {
        vertical: true
        disabled: $element.hasClass 'slider-disabled'
        horizontal: false
        y: valueAccessor()()
      }
      $element.data 'slider', slider

    # Discover if this slider is within a slider group.
    slidergroup = $element.parents '.slider-group'
    
    # This slider isn't grouped, updating the decimal value is one to one, we don't have to distribute.
    if !slidergroup.length
      slider.animationCallback = (x, y) ->
        if valueAccessor()() is slider.value.target[1]
          return
        valueAccessor() slider.value.target[1]
      return
    
    # This slider is in a group, we should access the other sliders in the group and scale them as we move.
    sliders = slidergroup.data 'sliders'
    
    if !sliders?
      sliders = []
    
    sliders.push slider
    
    slidergroup.data 'sliders', sliders
    
    # The distribute behaviour is attached to the animation callback so the other sliders update in realtime.
    slider.animationCallback = (x, y) ->
      valueAccessor() y
      
      current = @
      others = _.filter(sliders, (s) -> s isnt current)
      
      # Calculate the amount that is in the sliders that aren't moving.
      otherstotal = _.reduce(
        others,
        (memo, s) -> memo + s.value.current[1],
        0)
      alltotal = otherstotal + y
      totaldifference = alltotal - 1.0
      
      # A zero amount can't be scaled. The amount is distributed by portion instead.
      if otherstotal is 0
        split = totaldifference / others.length
        _.each(others, (s) ->
          currenty = s.value.current[1]
          s.setValue x, currenty - split, true
        )
        return
      
      # When we have an amount in other sliders the amount changed is distributed proportionally to the existing amounts in each slider.
      _.each(others, (s) ->
        currenty = s.value.current[1]
        scale = currenty / otherstotal
        s.setValue x, currenty - scale * totaldifference, true
      )
  
  # Update
  # ------
  update: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    slider = $(element).data 'slider'
    
    # The slider widget is updated with the new amount
    value = ko.utils.unwrapObservable(valueAccessor())
    if slider.value.target[1] != value
      slider.setValue 0, value
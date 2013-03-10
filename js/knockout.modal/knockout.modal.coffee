# Bindings for Bootstrap Modal 
# ============================
# 
# This plugin lets a boolean value show and hide a bootstrap modal dialog.

ko.bindingHandlers.modal =
  # Initialise
  # ----------
  init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    allBindings = allBindingsAccessor()
    $element = $ element

    # By default the modal is hidden
    $element.addClass 'hide modal'

    # Pass a function to the binding 'beforeOpen' to be called when the dialog is opening.
    if allBindings.modalOptions
      if allBindings.modalOptions.beforeOpen
        $element.on 'show', () ->
          allBindings.modalOptions.beforeOpen()

    # Pass a function to the binding 'beforeClose' to be called when the dialog is closing.
    if allBindings.modalOptions
      if allBindings.modalOptions.beforeClose
        $element.on 'hide', () ->
          allBindings.modalOptions.beforeClose()

    # Bind descendants on shown, once only
    shown = false
    $element.on 'shown', () ->
      if !shown
        ko.applyBindingsToDescendants bindingContext, element
        shown = true
      else
        # Once shown refresh any internal widgets. For the moment only sliders are refreshed.
        $element.find('.slider').each((key, slider) ->
          data = $(slider).data 'slider'
          data.setup() if data
        )

    # Closing the modal will set the value to false
    $element.on 'hidden', () ->
      valueAccessor() false

    return { controlsDescendantBindings: true };

  # Update
  # ------
  update: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    value = ko.utils.unwrapObservable valueAccessor()

    # Check the value bound. If true show the dialog. If false hide the dialog.
    if value
      $(element).modal 'show'
    else
      $(element).modal 'hide'
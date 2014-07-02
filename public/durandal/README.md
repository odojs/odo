# Odo durandal enhancements
Durandal provides some simple guidelines and utilities to help build a module single page application. See [the durandal website](http://durandaljs.com/) for [more information](http://durandaljs.com/documentation/Durandal-Edge.html).

**Durandal 2.0 is merging with Angular 1.0 to become Angular 2.0**
This project may be upgraded to support Angular 2.0 when it's released.

# Overview
Durandal has been extended with components, plugins and custom transitions. Additionally a css file is provided for common styles.

Components are [reusable containers](http://durandaljs.com/documentation/Using-Composition.html) to help with common user interface techniques such as dialogs and multi-step wizards.

Plugins extend, replace or provide additionally functionality to the durandal ecosystem. Extension points are durandal, requirejs and knockout binding handlers.

Transitions are implemented with [velocity.js](http://julian.com/research/velocity/) and provide interaction hints when navigating between views.

The provided css includes a few reusable modules along with configuration for animation and dialogs.

# Components
## Dialog
The existing durandal dialog required subclassing and didn't fit nicely with the rest of how durandal works. This replacement, along with it's associated plugin, lets any view become a dialog. The `canActivate` and `activate` methods of the inner view are called with an object that carries both the dialog itself, so commands can be issued, and `activationData` from the initial call to dialog, so views can pass information into dialogs.

```coffee
define ['knockout'], (ko) ->
    class EditNameDialog
        activate: (options) =>
            { @dialog, activationData } = options
            
            @user = activationData
            
            # @dialog.close()

```

Dialogs have some fundamental issues with tablets that are hard to get around. It's recommended to have all interactions inline if tablet support is important.

## Wizard
Multi-step processes break up long forms into individual operations that are simplier and require less cognitive overhead. The wizard components hosts views and provides methods to navigate forward and back to new views while passing data between each step. It's non-linear and doesn't require the set of steps to be defined in advance.

```coffee
define ['knockout'], (ko) ->
    class EditNameStep
        activate: (options) =>
            { @wizard, activationData } = options
            
            @user = activationData
            
        
        forward: =>
            options =
                model: 'user/profile/review'
                activationData: @user
            @wizard.forward(options)()
```

There is a special case when a wizard is within a dialog. Both components can be accessed

```coffee
{ @wizard, @dialog, activationData } = options
```

# Plugins
Each plugin, when included, will extend or register itself to the right place in the system. Plugins aren't interacted with directy.

## [Bootstrap](http://getbootstrap.com/)
Binding handlers to help bootstrap javascript integrate well with knockoutjs is included here.

## [Dialog](http://durandaljs.com/documentation/Showing-Message-Boxes-And-Modals.html)
This plugin replaces the existing dialog with the new component based implementation.

## [Marked](https://github.com/chjj/marked)
This plugin provides binding handlers for marked - a markdown parser.

## [Mousetrap](http://craig.is/killing/mice)
This plugin provides binding handers for Mousetrap - for key bindings. Mousetrap is extended to allow unbinding so Moustrap can be used on multiple views, such as steps in a wizard.

## [Q](https://github.com/kriskowal/q)
This plugin [extends durandal to use Q promises internally](http://durandaljs.com/documentation/Q.html), enhances requirejs to allow modules to return promises and generally does a lot of magic and is probably a bit fragile as a result.

```coffee
define ['odo/auth/current-user'], (currentUser) ->
    console.log currentUser.displayName
```

```coffee
define ['q', 'odo/auth'], (Q, auth) ->
    dfd = Q.defer()
    auth
        .getUser()
        .then((user) ->
            dfd.resolve user)
        .fail((err) ->
            dfd.resolve null)
    dfd.promise
```

## [Router](http://durandaljs.com/documentation/Using-The-Router.html)
This plugin adds extra functionality to durandal's router to pull a title from any current view, enable or disable the router, remember the current instruction, and dynamic transitions.

```coffee
define ['knockout'], (ko) ->
    class Page
        title: 'My First Page'
        
        constructor: ->
            @title = ko.observable
        
        activate: (name) ->
            @title = "My First Page - #{name}"
            
```

```coffee
router.transition '#user/tcoats', 'forward'
```

## Validation
Validation is provided through [knockout validation](https://github.com/Knockout-Contrib/Knockout-Validation). This plugin provides some sensible defaults. It's probably best to use this [forked version of knockout validation](https://github.com/tcoats/Knockout-Validation) for better async support.

## [ViewLocator](http://durandaljs.com/documentation/View-Location.html)
This plugin provides a sensible default for view location - `/views`.

## [Widget](http://durandaljs.com/documentation/Creating-A-Widget.html)
This plugin provides a sensible default for widget location - `/local/widgets/`.


# [Transitions](http://durandaljs.com/documentation/Creating-A-Transition.html)
All transitions make use of the base class `velocity.coffee` which handles the general sequence of events.

## Back, forward
These transitions slide forward or back and are useful for spacial navigation. They are used by the wizard.

## Dynamic
This transition is provided for the router.transition extension. As there is no way for the router to pass through a transition, this implementation looks up the transition from the router directly. It will fallback to no transition if router.transition was not used.

```html
<div data-bind="router: { cacheViews: true, transition: 'dynamic' }"></div>
```




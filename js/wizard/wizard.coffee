#
#    Wizard - display non-linear step by step processes
#
# Version: 1.0
# Author: Luke McGregor
# Based on: enlighten.wizard.js (Thomas Coats)
#
# Features:
#
# 1.  Custom non-linear steps:
#
#   <div class='wizard'>
#     <div class='inner'>
#       <div id='start' class='pane'>
#         <h1>Menu</h2>
#
#         <button href='#settings' class='goleft'>Settings</button>
#         <button href='#assign' class='goright'>Assign</button>
#       </div>
#       <div id='settings' class='pane'>
#         <h1>Settings</h2>
#
#         <button href='#start' class='goright'>Cancel</button>
#       </div>
#       <div id='assign' class='pane'>
#         <h1>Assign</h2>
#
#         Name: <input type='text' />
#         
#         <button href='#assigned' class='goright'>Assign</button>
#         <button href='#start' class='left'>Cancel</button>
#       </div>
#       <div id='assigned' class='pane'>
#         <h1>Assign</h2>
#         <button href='#start' class='goleft'>Go to start Left</button>
#         <button href='#start' class='goright'>Go to start Right</button>
#       </div>
#     </div>
#   </div>
#
# 2.  Automatic binding of actions:
#   
#   class='goleft' - using the href of the element as a selector of the pane it will place it to the left and then move to it.
#   class='goright' - using the href of the element as a selector of the pane it will place it to the right and then move to it.
#   class='shake' - shake the wizard
#
#   class='submit' - if you want to have the pane trigger validation (not defined in this file)
#
# 3.  API functionality:
#   
#   $(selector).wizard().goleft()
#   $(selector).wizard().goright()
#   $(selector).wizard().shake()
#
# 4.  Start it up by:
#
#   $(function(){
#     $('.wizard').wizard();
#   });
#
# Required CSS:
#
#   .wizard,
#   .wizard > .inner > .pane {
#     padding: 0px;
#     overflow: hidden;
#   }
#
#   .wizard > .inner {
#     overflow: hidden;
#   }
#
#   .wizard > .inner > .pane {
#     padding: 0px;
#     float: left;
#   }
#
(($) ->
  $.wizard = (options, target) ->
    @options = $.extend(true, {}, $.wizard.defaults, options)
    @target = target
    @init()
    @

  $.extend $.wizard,
    defaults:
      delay: 400
      width: 760 # width of target
      easing: 'swing'
      current: null # set this to a pane, otherwise it will pick the first '.pane' in the '.inner' div
      bind: true

    prototype:
      init: ->
        wizard = @
        @options.width = @target.innerWidth()  unless @options.width
        @inner = @target.children('.inner')
        @inner.find('.pane').hide()
        
        # setup current if it's not set
        unless @options.current
          @current = @inner.find('.pane').first()
          @current.show()
        if @options.bind
          @target.find('.goleft').click (e) ->
            e.preventDefault()
            wizard.goleft $($(@).attr('href'))

          @target.find('.goright').click (e) ->
            e.preventDefault()
            wizard.goright $($(@).attr('href'))

          @target.find('.shake').click (e) ->
            e.preventDefault()
            wizard.shake()

        @inner.find('.pane').width @options.width
        @target.width @options.width
        @inner.width @options.width * 2

      goleft: (transitionTo, f) ->
        wizard = @
        
        #move the current pane to the left 
        wizard.current.before transitionTo
        
        #show the current pane and re-adjust the viewport so its pointing at the current screen
        transitionTo.show()
        wizard.inner.css 'margin-left', -1 * wizard.options.width + 'px'
        
        #transition in the new pane
        wizard.inner.animate
          marginLeft: '+=' + wizard.options.width + 'px'
        ,
          easing: wizard.options.easing
          duration: wizard.options.delay
          complete: ->
            wizard.current.hide()
            wizard.current = transitionTo

        @

      goright: (transitionTo, f) ->
        wizard = @
        
        #move the current pane to the right 
        wizard.current.after transitionTo
        
        #show the current pane and re-adjust the viewport so its pointing at the current screen
        transitionTo.show()
        
        #transition in the new pane
        wizard.inner.animate
          marginLeft: '-=' + wizard.options.width + 'px'
        ,
          easing: wizard.options.easing
          duration: wizard.options.delay
          complete: ->
            wizard.current.hide()
            wizard.inner.css 'margin-left', '0px'
            wizard.current = transitionTo

        @

      shake: ->
        wizard = @
        wizard.target.stop()
        wizard.target
          .animate('margin-left': '+=10px', 50)
          .animate('margin-left': '-=20px', 100)
          .animate('margin-left': '+=20px', 100)
          .animate('margin-left': '-=20px', 100)
          .animate 'margin-left': '+=10px', 50, ->
            wizard.target.css('margin-left', 'auto').stop()

        @

  $.fn.wizard = (options, params) ->
    result = null
    @each ->
      # check if a wizard for this element was already created
      wizard = $.data @, 'wizard'
      if wizard
        # shortcut to api call - next, prev etc.
        if typeof options is 'string'
          if params
            wizard[options] params
          else
            wizard[options]()
      else
        wizard = new $.wizard options, $ @

        $.data @, 'wizard', wizard
      
      result = wizard
    result
) jQuery
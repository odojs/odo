define ['knockout', 'mousetrap', 'jquery', 'durandal/system', 'q'], (ko, Mousetrap, $, system, Q) ->
	init: ->
		Mousetrap = ((Mousetrap) ->
			_originalBind = Mousetrap.bind
			
			Mousetrap.bind = (keys, originalCallback, action) ->
				# local variable to control the callback
				isBound = true

				# an object returned that allows the calling code to unbind and re-bind the configured binding
				handle =
					unbind: ->
						isBound = false
					bind: ->
						isBound = true

				# add a layer to the callback with the isBound switch that the handle can turn on and off
				callback = ->
					return unless isBound
					originalCallback.apply @, arguments
				_originalBind keys, callback, action
				handle
				
			Mousetrap
		)(Mousetrap)
		
		
		Mousetrap.stopCallback = (e, element, combo) ->
			$element = $ element
			
			# mousetrap goes into things with the class mousetrap-yes
			if $element.hasClass 'mousetrap-yes'
				return false
			
			# mousetrap goes into things with the class mousetrap-yes-[combo] e.g. mousetrap-yes-up
			if $element.hasClass('mousetrap-yes-' + combo)
				return false
			
			# stop for input, select, and textarea
			element.tagName is 'INPUT' or element.tagName is 'SELECT' or element.tagName is 'TEXTAREA' or (element.contentEditable and element.contentEditable is 'true')
		
		system.defer = (action) ->
			deferred = Q.defer()
			action.call deferred, deferred
			promise = deferred.promise
			deferred.promise = ->
				promise

			deferred
		
		ko.bindingHandlers.popover = init: (element, valueAccessor) ->
			options = ko.unwrap valueAccessor()
			console.log 'popover initialized'
			$(element).popover options
		
		ko.bindingHandlers.shortcuts = init: (element, valueAccessor) ->
			
			wrap = (handler, key) ->
				->
					handler key
					no
			
			shortcuts = ko.unwrap valueAccessor()
			handles = []
			
			for key, handler of shortcuts
				 handles.push Mousetrap.bind key, wrap handler, key
				
			ko.utils.domNodeDisposal.addDisposeCallback element, ->
				for handle in handles
					handle.unbind()

define ['knockout', 'jquery'], (ko, $) ->
	init: (requirejs, config) ->
		if config.dialog
			requirejs ['plugins/dialog'], (dialog) ->
				dialog.addContext 'OdoDialog',
					compositionComplete: (child, parent, context) ->
						$child = $ child
						
						options =
							backdrop: 'static'
						
						theDialog = dialog.getDialog context.model
						$host = $ theDialog.host
						$host.modal(options)
						
						# in practice we use a dialog component so this doesn't work -- probably should rethink how this works
						if $child.hasClass 'autoclose'
							$host.one 'shown.bs.modal', ->
								$host.one 'click.dismiss.modal', ->
									theDialog.close()
						
					
					addHost: (theDialog) ->
						body = $ 'body'
						host = $('<div class="modal fade" id="odo-modal" tabindex="-1" role="dialog" aria-hidden="true">')
							.appendTo(body)
						theDialog.host = host.get 0
					
					removeHost: (theDialog) ->
						$(theDialog.host)
							.one('hidden.bs.modal', ->
								ko.removeNode theDialog.host
							)
							.modal 'hide'
		
		if config.mousetrap
			requirejs ['mousetrap'], (Mousetrap) ->
		
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
		
		
		if config.q
			requirejs ['durandal/system', 'q'], (system, Q) ->
				system.defer = (action) ->
					deferred = Q.defer()
					action.call deferred, deferred
					promise = deferred.promise
					deferred.promise = ->
						promise

					deferred
		
		if config.bootstrap
			ko.bindingHandlers.popover = init: (element, valueAccessor) ->
				options = ko.unwrap valueAccessor()
				$(element).popover options
				
		if config.marked
			requirejs ['marked'], (marked) ->
				ko.bindingHandlers.marked =
					init: () ->
						{ 'controlsDescendantBindings': true }
							
					update: (element, valueAccessor) ->
						ko.utils.setHtml element, marked ko.utils.unwrapObservable valueAccessor()
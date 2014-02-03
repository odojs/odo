define ['knockout', 'jquery'], (ko, $) ->
	init: (requirejs, config) ->
		if config.dialog
			requirejs ['plugins/dialog', 'plugins/router'], (dialog, router) ->
				dialog.addContext 'OdoDialog',
					compositionComplete: (child, parent, context) ->
						$child = $ child
						
						options =
							backdrop: 'static'
						
						theDialog = dialog.getDialog context.model
						$host = $ theDialog.host
						$host.modal options
						
						# rebuild autofocus functionality - bootstrap messes with it
						$host.one 'shown.bs.modal', ->
							$child.find('[autofocus],.autofocus').first().focus()
						
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
						if config.router
							router.disable()
					
					removeHost: (theDialog) ->
						$(theDialog.host)
							.one('hidden.bs.modal', ->
								ko.removeNode theDialog.host
								if config.router
									router.enable()
							)
							.modal 'hide'
		
		if config.validation
			requirejs ['knockout', 'ko.validation'], () ->
				ko.validation.configure
					registerExtenders: true
					parseInputAttributes: true
					insertMessages: no
					errorMessageClass: 'help-block'
					errorElementClass: 'has-error'
		
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
				
				# use Q promises internally in durandal
				system.defer = (action) ->
					deferred = Q.defer()
					action.call deferred, deferred
					promise = deferred.promise
					deferred.promise = ->
						promise

					deferred
				
				# a version of require that returns a promise immediately
				window.requireQ = (deps) ->
					dfd = Q.defer()
					requirejs deps, ->
						dfd.resolve arguments
					dfd.promise
				
				originalDefine = window.define
				# a version of define that waits until all deps have been required, and if they are promises waits for those as well
				window.defineQ = (name, deps, callback) ->
					
					method = (cb) ->
						->
							that = @
							dfd = Q.defer()
							args = Array::slice.call arguments, 0
							
							Q
								.all(args)
								.then (resolved) ->
									dfd.resolve cb.apply that, resolved
							
							dfd.promise
					
					# magical argument detection, needed so we know which argument is the callback, otherwise we would just .apply arguments
					
					if typeof name isnt 'string'
						if system.isArray name
							# defineQ(deps, callback)
							args = [name, method(deps)]
						else
							# defineQ(callback)
							args = [method(name)]
					
					else if !system.isArray deps
						# defineQ(name, callback)
						args = [name, method(deps)]
					
					else
						# defineQ(name, deps, callback)
						args = [name, deps, method(callback)]
					
					originalDefine.apply @, args
				
				# when durandal is looking for deps, make sure we are okay if they return promises instead of the actual module
				system.acquire = ->
					deps = undefined
					first = arguments[0]
					arrayRequest = false
					if system.isArray(first)
						deps = first
						arrayRequest = true
					else
						deps = Array::slice.call arguments, 0
					@defer((dfd) ->
						requireQ(deps)
							.spread(->
								args = arguments
								setTimeout (->
									if args.length > 1 or arrayRequest
										dfd.resolve Array::slice.call args, 0
									else
										dfd.resolve args[0]
								), 1
							)
							.fail (err) ->
								dfd.reject err

					).promise()
				
				# can set module id on a promised object - it simply waits
				originalSetModuleId = system.setModuleId
				system.setModuleId = (obj, id) ->
					if system.isPromise obj
						obj.then (newObj) ->
							originalSetModuleId newObj, id
						return
					
					originalSetModuleId obj, id
		
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
		
		if config.router
			requirejs ['plugins/router', 'durandal/app'], (router, app) ->
				subscription = null
				router.updateDocumentTitle = (instance, instruction) ->
					if subscription?
						subscription.dispose()
						subscription = null
					
					update = ->
						parts = []
						
						if instance.title?
							parts.push ko.unwrap instance.title
							
						if instruction.config.title?
							parts.push instruction.config.title
						
						if app.title?
							parts.push app.title
						
						# clear out any empty strings
						parts = parts.filter (part) -> part isnt ''
						
						document.title = parts.join ' - ' 
					update()
					
					# changes to an observable title are reflected
					if instance.title? and ko.isObservable instance.title
						subscription = instance.title.subscribe ->
							update()
				
				# disable and enable a router
				isRouterEnabled = yes
				router.disable = ->
					isRouterEnabled = no
				
				router.enable = ->
					isRouterEnabled = yes
				
				previousInstruction = null
				router.guardRoute = (instance, instruction) ->
					if previousInstruction? and !isRouterEnabled
						return previousInstruction.fragment
					
					previousInstruction = instruction
					
					yes
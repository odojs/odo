define ['knockout', 'plugins/router', 'durandal/app'], (ko, router, app) ->
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
	
	router.currentInstruction = null
	router.guardRoute = (instance, instruction) ->
		if router.currentInstruction? and !isRouterEnabled
			return router.currentInstruction.fragment
		
		router.currentInstruction = instruction
		
		yes

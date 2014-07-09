define ['plugins/router', 'q'], (router, Q) ->
	(context) ->
		dfd = Q.defer()
		if router.currentTransition?
			requirejs ['transitions/' + router.currentTransition], (transition) ->
				transition(context).then -> dfd.resolve()
		else
			context.scrolltop = yes if !context.scrolltop?
			$(context.activeView).hide() if context.activeView?
			if context.child?
				context.triggerAttach()
				view = $(context.child).show()
				
				# scroll to the top of the element for a transition
				if context.scrolltop? and $(window).scrollTop() > view.offset().top
					$('html, body').css({ scrollTop: view.offset().top })
					
				view.find('[autofocus],.autofocus').first().focus()
			dfd.resolve()
		dfd.promise

define [
	'durandal/system'
	'plugins/router'
	'q'
	'./animate.css'
], (system, router, Q, Animate) ->
	
	
	result = (context) ->
		defered = Q.defer()
		if router.currentTransition?
			console.log 'We have a transition ' + router.currentTransition
			requirejs ['transitions/' + router.currentTransition], (transition) ->
				transition(context).then defered.resolve()
		else
			console.log 'No transition for this one'
			context.scrolltop = yes if !context.scrolltop?
			$(context.activeView).hide() if context.activeView?
			if context.child?
				context.triggerAttach()
				view = $(context.child).show()
				
				# scroll to the top of the element for a transition
				if context.scrolltop? and $(window).scrollTop() > view.offset().top
					$('html, body').css({ scrollTop: view.offset().top })
					
				view.find('[autofocus],.autofocus').first().focus()
			defered.resolve()
		defered.promise
		
		#system.extend context, {
		#	inAnimation: 'fadeInDown'
		#	outAnimation: 'fadeOutDown'
		#}
		#new Animate().create context

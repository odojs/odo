define ['durandal/system', 'jquery', 'q'], (system, $, Q) ->
	class Animate
		create: (@settings) =>
			@deferred = Q.defer()
			if !@settings.scrolltop?
				@settings.scrolltop = yes
			if @settings.child
				@startTransition()
			else
				@endTransition()
			@deferred.promise
				
		startTransition: =>
			if @settings.activeView?
				@outTransition()
			else
				@inTransition()
		
		endTransition: =>
			@deferred.resolve()
		
		outTransition: =>
			$previousView = $ @settings.activeView
			$previousView.addClass 'transition'
			$previousView.addClass 'animated'
			$previousView.addClass @settings.outAnimation
			
			setTimeout(=>
				$previousView.hide()
				@inTransition()
				@endTransition()
			, 200)
		
		inTransition: =>
			@settings.triggerAttach()
			$newView = $(@settings.child)
			$newView.addClass 'transition'
			$newView.addClass 'animated'
			$newView.show()
			$newView.addClass @settings.inAnimation
			
			# scroll to the top of the element for a transition
			if @settings.scrolltop? and $(window).scrollTop() > $newView.offset().top
				$('html, body').animate({
						scrollTop: $newView.offset().top
				}, 300)

			setTimeout(=>
				$newView.removeClass @settings.inAnimation
				$newView.removeClass @settings.outAnimation
				$newView.removeClass 'transition'
				$newView.removeClass 'animated'
				@endTransition()
				$newView.find('[autofocus],.autofocus').first().focus()
			, 300)

define ['durandal/system', 'jquery', 'q', 'velocity'], (system, $, Q) ->
	class Velocity
		animations:
			slideInRight:
				translateX: ['0px', '2000px']
			slideInLeft:
				translateX: ['0px', '-2000px']
			slideOutRight:
				translateX: ['2000px', '0px']
			slideOutLeft:
				translateX: ['-2000px', '0px']
				
		
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
			$previousView.velocity(
				@animations[@settings.outAnimation],
				300,
				=>
					$previousView.removeClass 'transition'
					$previousView.hide()
					@inTransition()
					@endTransition()
			)
		
		inTransition: =>
			@settings.triggerAttach()
			$newView = $(@settings.child)
			
			$newView.addClass 'transition'
			$newView.velocity(
				@animations[@settings.inAnimation],
				300,
				=>
					$newView.css '-webkit-transform', ''
					$newView.css '-moz-transform', ''
					$newView.css '-ms-transform', ''
					$newView.css 'transform', ''
					$newView.removeClass 'transition'
					@endTransition()
					$newView.find('[autofocus],.autofocus').first().focus()
			)
			
			# scroll to the top of the element for a transition
			if @settings.scrolltop? and $(window).scrollTop() > $newView.offset().top
				$('html, body').velocity({
						scrollTop: $newView.offset().top
				}, 300)

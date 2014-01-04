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
				
		startTransition: () =>
			if @settings.activeView?
				@outTransition @inTransition
			else
				@inTransition()
		
		endTransition: () =>
			@deferred.resolve()
		
		outTransition: (callback) =>
			$previousView = $ @settings.activeView
			$previousView.addClass 'animated'
			$previousView.addClass @settings.outAnimation
			
			setTimeout(() =>
				if callback?
					callback()
					@endTransition()
			, 200)
		
		inTransition: () =>
			@settings.triggerAttach()
			$newView = $(@settings.child)
				.removeClass([@settings.outAnimation, @settings.inAnimation])
				.addClass('animated')
			$newView.css 'display', ''
			$newView.addClass @settings.inAnimation
			
			# scroll to the top of the element for a transition
			if @settings.scrolltop $(window).scrollTop() > $newView.offset().top
				$('html, body').animate({
						scrollTop: $newView.offset().top
				}, 300);

			setTimeout(() =>
				$newView.removeClass(@settings.inAnimation + ' ' + @settings.outAnimation + ' animated')
				@endTransition()
			, 300)
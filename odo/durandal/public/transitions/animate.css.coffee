define ['durandal/system', 'jquery'], (system, $) ->
	class Animate
		create: (@settings) =>
			$.Deferred (deferred) =>
				@deferred = deferred
				if @settings.child
					@startTransition()
				else
					@endTransition()
				
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

			setTimeout(() =>
				$newView.removeClass(@settings.inAnimation + ' ' + @settings.outAnimation + ' animated')
				@endTransition()
			, 300)
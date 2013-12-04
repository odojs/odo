define ['durandal/system', './animate.css'], (system, Animate) ->
	(context) ->
		system.extend context, {
			inAnimation: 'slideInLeft'
			outAnimation: 'slideOutRight'
		}
		new Animate().create context

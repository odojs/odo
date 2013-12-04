define ['durandal/system', './animate.css'], (system, Animate) ->
	(context) ->
		system.extend context, {
			inAnimation: 'slideInRight'
			outAnimation: 'slideOutLeft'
		}
		new Animate().create context
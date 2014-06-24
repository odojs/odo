define ['durandal/system', './velocity'], (system, Velocity) ->
	(context) ->
		system.extend context, {
			inAnimation: 'slideInRight'
			outAnimation: 'slideOutLeft'
		}
		new Velocity().create context

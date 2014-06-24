define ['durandal/system', './velocity'], (system, Velocity) ->
	(context) ->
		system.extend context, {
			inAnimation: 'slideInLeft'
			outAnimation: 'slideOutRight'
		}
		new Velocity().create context

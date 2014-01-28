define [
	'odo/plugins'
	'odo/user/usercommands'
	'odo/user/userprofile'
], (Plugins, plugins...) ->
	
	new Plugins(plugins)
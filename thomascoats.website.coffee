requirejs = require 'requirejs'

# requirejs
requirejs.config {
		# Pass the top-level main.js/index.js require
		# function to requirejs so that node modules
		# are loaded relative to the top-level JS file.
		nodeRequire: require
		paths: {
		}
}

requirejs ['odo/express'], (express) ->
	
	process.env.PORT = 80
	
	app = express [
		requirejs './odo/plugins/peek'
		requirejs './odo/plugins/bower'
		requirejs './odo/plugins/durandal'
		requirejs './odo/plugins/handlebars'
		requirejs './odo/plugins/twitterauth'
		requirejs './thomascoats.com/plugins/public'
		requirejs './thomascoats.com/plugins/article'
	]
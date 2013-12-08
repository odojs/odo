requirejs.config
	# work out a way for each odo plugin to insert itself here?
	paths:
		text: 'requirejs-text/text'
		durandal: 'durandal/js'
		plugins: 'durandal/js/plugins'
		knockout: 'knockout.js/knockout'
		bootstrap: 'bootstrap/dist/js/bootstrap.min'
		jquery: 'jquery/jquery.min'
		underscore: 'underscore/underscore-min'
		mousetrap: 'mousetrap/mousetrap.min'
		uuid: 'node-uuid/uuid'
		transitions: 'odo/durandal/transitions'
		components: 'odo/durandal/components'
		odo: 'odo'

	shim:
		bootstrap:
			deps: ['jquery']
			exports: 'jQuery'
		underscore:
			exports: '_'
		mousetrap:
			exports: 'Mousetrap'
	
	# don't cache in development
	urlArgs: 'v=' + (new Date()).getTime()

define ['durandal/system', 'durandal/app', 'durandal/viewLocator', 'odo/durandal/bindings'], (system, app, locator, bindings) ->
		system.debug true
		app.title = 'thomascoats.com'
		app.configurePlugins
			router: true
			dialog: true
			widget: true
		
		bindings.init()

		app.start().then ->
			#Replace 'viewmodels' in the moduleId with 'views' to locate the view.
			#Look for partial views in a 'views' folder in the root.
			locator.useConvention 'views'
			
			#Show the app by setting the root view model for our application
			app.setRoot 'views/shell'
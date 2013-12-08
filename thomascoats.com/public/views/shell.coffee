define ['plugins/router', 'durandal/app', 'bootstrap'], (router, app, bootstrap) ->
	router: router
	activate: ->
		router.map([
			{
				route: ''
				moduleId: 'views/search'
				nav: false
			}
			{
				route: 'welcome'
				moduleId: 'views/welcome'
				nav: false
			}
			{
				route: 'articles/:id/:name'
				moduleId: 'views/articles/view'
				nav: false
			}
		]).buildNavigationModel()
		router.activate()
	compositionComplete: () ->
		$('.dropdown-toggle').dropdown()
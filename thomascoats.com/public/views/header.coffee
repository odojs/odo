define ['q', 'knockout', 'odo/auth/twitter'], (Q, ko, twitterauth) ->
	class Header
		activate: =>
			dfd = Q.defer()
			twitterauth.getUser()
				.then((user) =>
					@user user
					dfd.resolve yes
				)
				.fail(->
					dfd.resolve no
				)
			dfd.promise
		
		user: ko.observable null
		
		compositionComplete: () ->
			$('#nav-main').tooltip {
				selector: '.tooltip-toggle'
				container: 'body'
			}
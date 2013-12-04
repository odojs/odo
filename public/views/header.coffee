define ['knockout', 'odo/auth/twitter'], (ko, twitterauth) ->
	class Header
		activate: =>
			$.Deferred((deferred) =>
				twitterauth.getUser (err, user) =>
					if err?
						deferred.resolve false
						return
					
					@user user
					deferred.resolve true
			).promise()
		
		user: ko.observable null
		
		compositionComplete: () ->
			$('#nav-main').tooltip {
				selector: '.tooltip-toggle'
				container: 'body'
			}
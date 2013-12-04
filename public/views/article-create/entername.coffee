define ['knockout'], (ko) ->
	class EnterName
		constructor: ->
			@articlename = ko.observable ''
			
		activate: (options) =>
			{ @wizard, @dialog, activationData } = options
			@articlename activationData
		
		submit: =>
			
		
		close: =>
			@dialog.close()
			
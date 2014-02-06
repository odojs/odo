define ['knockout', 'jquery', 'plugins/dialog'], (ko, $, dialog) ->
	
	class Dialog
		constructor: (options) ->
			@composeOptions = ko.observable null
			@shouldShake = ko.observable no
			activationData = {
				dialog: @
				activationData: options.activationData
			}
			
			@composeOptions
				model: options.model
				activationData: activationData
		
		show: =>
			dialog.showOdoDialog @
		
		close: (response) =>
			dialog.close @, response
		
		shake: =>
			@shouldShake true
			
			setTimeout(() =>
				@shouldShake false
			, 1000)
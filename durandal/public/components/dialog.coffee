define ['knockout', 'jquery', 'plugins/dialog'], (ko, $, dialog) ->
	
	class Dialog
		composeOptions: ko.observable null
		shouldShake: ko.observable no
		
		constructor: (options) ->
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
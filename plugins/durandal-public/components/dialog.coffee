define ['knockout', 'jquery', 'plugins/dialog'], (ko, $, dialog) ->
	
	class Dialog
		constructor: (options) ->
			activationData = {
				dialog: @
				activationData: options.activationData
			}
			
			@composeOptions = ko.observable {
				model: options.model
				activationData: activationData
			}
			@shouldShake = ko.observable false
		
		show: =>
			dialog.showOdoDialog @
		
		close: (response) =>
			dialog.close @, response
		
		shake: =>
			@shouldShake true
			
			setTimeout(() =>
				@shouldShake false
			, 1000)
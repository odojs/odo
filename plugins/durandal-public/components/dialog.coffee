define ['knockout', 'jquery', 'durandal/system', 'plugins/dialog'], (ko, $, system, dialog) ->
	
	class Dialog
		constructor: (options) ->
			activationData = {
				dialog: @
			}
			system.extend activationData, options.activationData
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
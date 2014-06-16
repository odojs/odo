define ['knockout'], (ko) ->
	class Wizard
		constructor: ->
			@composeOptions = ko.observable {
				model: ''
				activationData: {
					wizard: @
					activationData: null
				}
			}
		
		activate: (options) =>
			@dialog = options.dialog
			@composeOptions {
				model: options.model
				activationData: {
					dialog: @dialog
					wizard: @
					activationData: options.activationData
				}
			}
		
		forward: (options) =>
			() =>
				@composeOptions {
					model: options.model
					transition: 'forward'
					activationData: {
						dialog: @dialog
						wizard: @
						activationData: options.activationData
					}
				}
		
		back: (options) =>
			() =>
				@composeOptions {
					model: options.model
					transition: 'back'
					activationData: {
						dialog: @dialog
						wizard: @
						activationData: options.activationData
					}
				}
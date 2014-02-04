define ['knockout', 'ko.validation'], (ko) ->
	ko.validation.configure
		registerExtenders: true
		parseInputAttributes: true
		insertMessages: no
		errorMessageClass: 'help-block'
		errorElementClass: 'has-error'
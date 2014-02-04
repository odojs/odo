define ['knockout', 'jquery'], (ko, $) ->
	ko.bindingHandlers.popover = init: (element, valueAccessor) ->
		options = ko.unwrap valueAccessor()
		$(element).popover options
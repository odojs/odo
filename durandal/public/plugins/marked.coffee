define ['knockout', 'marked'], (ko, marked) ->
	ko.bindingHandlers.marked =
		init: () ->
			{ 'controlsDescendantBindings': true }
				
		update: (element, valueAccessor) ->
			ko.utils.setHtml element, marked ko.utils.unwrapObservable valueAccessor()
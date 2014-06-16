define ['plugins/widget'], (widget) ->
	widget.convertKindToModulePath = (kind) ->
		"local/widgets/#{kind}"
		
	widget.convertKindToViewPath = (kind) ->
		"local/widgets/#{kind}"
define ['plugins/widget'], (widget) ->
	widget.convertKindToModulePath = (kind) ->
		return kind if '/' in kind
		"local/widgets/#{kind}"
		
	widget.convertKindToViewPath = (kind) ->
		return kind if '/' in kind
		"local/widgets/#{kind}"
$ () ->
	$('#admin-plugin input').change (e) ->
		$input = $ this
		$label = $input.parent 'label'
		id = $input.attr 'name'
		checked = $input.prop 'checked'
		$label.toggleClass 'plugin-disabled', !checked
		$.post id + '/', { disabled: !checked }
define [], ->
	# Wait x miliseconds before calling a function
	# Additional parameters are passed to the function
	(wait, func) ->
		args = Array::slice.call arguments, 2
		apply = -> func.apply(null, args)
		setTimeout apply, wait

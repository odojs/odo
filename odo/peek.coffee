define ['peekinto'], (peek) ->
	# Peek into a request, perform processing but not be responsible for the output.
	configure: (app) ->
		peek app
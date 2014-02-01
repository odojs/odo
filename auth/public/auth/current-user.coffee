define ['q'], (Q) ->
	
	
	
	
	
	
	
	dfd = Q.defer()
	
	setTimeout (->
		dfd.resolve 'Win!'
	), 2000
	
	dfd.promise
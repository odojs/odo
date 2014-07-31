define [], ->
	series: (tasks, callback) ->
		tasks = tasks.slice 0
		next = (cb) ->
			return cb() if tasks.length is 0
			task = tasks.shift()
			task -> next cb
		result = (cb) -> next cb
		result(callback) if callback?
		result

	parallel: (tasks, callback) ->
		count = tasks.length
		result = (cb) ->
			return cb() if count is 0
			for task in tasks
				task ->
					count--
					cb() if count is 0
		result(callback) if callback?
		result

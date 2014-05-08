define ['cson'], (CSON) ->
	(path, cb) ->
		CSON.parseFile path, (err, data) -> cb data

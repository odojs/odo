define [], ->
	(string, payload) ->
		return string if !payload?
		string.replace /{([^{}]+)}/g, (original, key) ->
			return original if !payload[key]?
			payload[key]

define ['module', 'fs', 'path', 'cson'], (module, fs, path, CSON) ->
	CSON.parseFileSync path.join path.dirname(module.uri), '../../config.cson'

define ['module', 'fs', 'path'], (module, fs, path) ->
	configpath = path.join path.dirname(module.uri), '../config.json'
	JSON.parse fs.readFileSync(configpath), 'utf-8'
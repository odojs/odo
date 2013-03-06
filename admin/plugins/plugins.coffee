fs = require 'fs'
path = require 'path'
_ = require 'underscore'

findplugin = (path, haystack) ->

	return haystack if path.length is 0
	return null if !haystack.plugins?

	needle = path[0]
	furtherpath = path.slice 1

	#console.log "At #{haystack.id} looking for #{needle}"

	plugin = _(haystack.plugins).find (plugin) ->
		plugin.id is needle

	#console.log "Found #{plugin.id}"

	findplugin furtherpath, plugin


module.exports =
	init: (app) ->
		app.post '/%CF%88/plugins/:id', (req, res) ->
			plugin = findplugin req.params.id.split('.'), {
				id: 'root'
				plugins: app.plugins.root
			}

			if !plugin?
				res.send 404
				return

			if req.body.disabled is 'true'
				plugin.config.disabled = true
			else
				delete plugin.config.disabled

			fs.writeFileSync plugin.configpath, JSON.stringify plugin.config, null, 2

			res.send 'okay'

		app.get '/%CF%88/plugins/', (req, res) ->
			res.locals.plugins = app.plugins.root

			res.render
				view: 'admin/layout'
				data:
					title: 'Ψ -> Enable and disable plugins'
					bodyclasses: ['prompt']
				partials:
					content: 'plugins/plugins'

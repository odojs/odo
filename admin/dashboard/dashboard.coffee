fs = require 'fs'
path = require 'path'
_ = require 'underscore'

module.exports =
	init: (app) ->
		app.get '/%CF%88/', (req, res) ->
			adminplugin = _(app.plugins.root).find (plugin) ->
				plugin.id is 'admin'

			res.locals.pluginsbycategory = _(adminplugin.plugins)
				.filter (plugin) ->
					plugin.config.disabled isnt true and plugin.config.category?

			res.locals.pluginsbycategory = _(res.locals.pluginsbycategory)
				.groupBy (plugin) -> plugin.config.category.toLowerCase()

			res.render
				view: 'admin/layout'
				data:
					title: 'Ψ'
					bodyclasses: ['full-admin']
				partials:
					content: 'dashboard/dashboard'

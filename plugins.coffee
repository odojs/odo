path = require 'path'
fs = require 'fs'
_ = require 'underscore'

control = {
  root: []

  # Load plugins from a directory into root
  loadplugins: (pluginspath) ->
    if _.isArray pluginspath
      for directory in pluginspath
        control.loadplugins path.join __dirname, directory
    else
      for plugin in control.parseforplugins pluginspath
        control.root.push plugin
    control.root

  # Configure all plugins in root
  configure: (app) ->
    control.configureplugins app, control.root

  # Init all plugins in root
  init: (app) ->
    control.initplugins app, control.root

  # Parse and load all plugins in a directory
  parseforplugins: (pluginspath) ->
    plugins = []
    if fs.existsSync pluginspath
      for directoryfile in fs.readdirSync pluginspath
        plugin = control.parseplugin path.join pluginspath, directoryfile

        plugins.push plugin if plugin?
    plugins

  # Parse a directory as a plugin
  # Will recurse and find sub-plugins
  parseplugin: (pluginpath) ->
    pluginfile = path.basename pluginpath

    plugin = {
      id: encodeURIComponent pluginfile
      filename: pluginfile
      path: pluginpath
    }

    # Only look at directories
    plugin.stat = fs.statSync plugin.path
    return if !plugin.stat.isDirectory()

    # Make sure it has the file `plugin.json`
    plugin.configpath = path.join plugin.path, 'plugin.json'
    return if !fs.existsSync plugin.configpath

    # Read the config and use it to find the entrypoint
    plugin.config = JSON.parse fs.readFileSync plugin.configpath, 'utf-8'
    plugin.pluginpath = path.normalize path.join plugin.path, plugin.config.main
    
    # Only load plugins that aren't disabled
    if plugin.config.disabled isnt true
      plugin.implementation = require plugin.pluginpath
    
    # Look for sub-plugins
    plugin.plugins = control.parseforplugins plugin.path

    plugin

  # Configure a list of plugins
  # Will recurse and configure sub-plugins
  configureplugins: (app, plugins) ->
    for plugin in plugins
      if plugin.implementation?.configure?
        plugin.implementation.configure app
      control.configureplugins app, plugin.plugins if plugin.plugins?

  # Init a list of plugins
  # Will recurse and init sub-plugins
  initplugins: (app, plugins) ->
    for plugin in plugins
      if plugin.implementation?.init?
        plugin.implementation.init app
      control.initplugins app, plugin.plugins if plugin.plugins?
}

module.exports = control
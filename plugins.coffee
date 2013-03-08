path = require 'path'
fs = require 'fs'
_ = require 'underscore'

control = {
  root: []

  # Load plugins from a directory into root
  loadplugins: (pluginspath, cb) ->
    pluginspaths = pluginspath
    pluginspaths = [pluginspaths] if !_.isArray pluginspath

    for directory in pluginspath
      directorypath = path.join __dirname, directory
      await control.parseforplugins directorypath, defer plugins

      if plugins?
        for plugin in plugins
          control.root.push plugin

    cb()

  # Parse and load all plugins in a directory
  parseforplugins: (pluginspath, cb) ->
    plugins = []

    await fs.exists pluginspath, defer exists
    if !exists
      cb null
      return
    
    await fs.readdir pluginspath, defer err, directoryfiles

    await
      for directoryfile in directoryfiles
        ((autocb) ->
          pluginfile = path.join pluginspath, directoryfile
          await control.parseplugin pluginfile, defer plugin
          plugins.push plugin if plugin?
        )(defer())

    cb plugins

  # Parse a directory as a plugin
  # Will recurse and find sub-plugins
  parseplugin: (pluginpath, cb) ->
    pluginfile = path.basename pluginpath

    plugin = {
      id: encodeURIComponent pluginfile
      filename: pluginfile
      path: pluginpath
    }

    # Only look at directories
    await fs.stat plugin.path, defer err, plugin.stat
    if !plugin.stat.isDirectory()
      cb null
      return 

    # Make sure it has the file `plugin.json`
    plugin.configpath = path.join plugin.path, 'plugin.json'
    await fs.exists plugin.configpath, defer exists
    if !exists
    #await fs.exists plugin.configpath, defer exists
    #if !exists
      cb null
      return

    # Read the config and use it to find the entrypoint
    await fs.readFile plugin.configpath, 'utf-8', defer err, configfile
    plugin.config = JSON.parse configfile
    plugin.pluginpath = path.normalize path.join plugin.path, plugin.config.main
    
    # Only load plugins that aren't disabled
    if plugin.config.disabled isnt true
      plugin.implementation = require plugin.pluginpath
    
    # Look for sub-plugins
    control.parseforplugins plugin.path, (plugins) ->
      plugin.plugins = plugins

    cb plugin

  # Configure all plugins in root
  configure: (app, cb) ->
    await control.configureplugins app, control.root, defer()
    cb()

  # Configure a list of plugins
  # Will recurse and configure sub-plugins
  configureplugins: (app, plugins, cb) ->
    await
      for plugin in plugins
        ((autocb) ->
          if plugin.implementation?.configure?
            plugin.implementation.configure app
          await control.configureplugins app, plugin.plugins, defer() if plugin.plugins?
        )(defer())
    cb()

  # Init all plugins in root
  init: (app, cb) ->
    await control.initplugins app, control.root, defer()
    cb()

  # Init a list of plugins
  # Will recurse and init sub-plugins
  initplugins: (app, plugins, cb) ->
    await
      for plugin in plugins
        ((autocb) ->
          if plugin.implementation?.init?
            plugin.implementation.init app
          await control.initplugins app, plugin.plugins, defer() if plugin.plugins?
        )(defer())
    cb()
}

module.exports = control
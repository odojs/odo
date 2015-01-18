define ['odo/config', 'consul-utils', 'cson'], (config, consul, CSON) ->
  (httpAddr, callback) ->
    firstRun = yes
    watch = new consul.KV httpAddr, "#{config.odo.domain}/odo-config", (configurations) ->
      for c in configurations
        config.import CSON.parseSync c.Value
      if firstRun
        firstRun = no
        callback()
// Generated by CoffeeScript 1.9.2
define(['odo/config', 'consul-utils', 'cson'], function(config, consul, CSON) {
  return function(httpAddr, callback) {
    var firstRun, watch;
    firstRun = true;
    return watch = new consul.KV(httpAddr, config.odo.domain + "/odo-config", function(configurations) {
      var c, i, len;
      for (i = 0, len = configurations.length; i < len; i++) {
        c = configurations[i];
        config["import"](CSON.parseCSONString(c.Value));
      }
      if (firstRun) {
        firstRun = false;
        return callback();
      }
    });
  };
});

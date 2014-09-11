define ['odo/config', 'redis'], (config, redis) ->
	->
		if config.redis.socket?
			redis.createClient config.redis.socket
		else
			redis.createClient config.redis.port, config.redis.host
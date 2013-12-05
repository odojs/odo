define ['redis'], (redis) ->

	# The hub encapsulates functionality to send or receive messages from redis.
	
	cmd = redis.createClient()
	evt = redis.createClient()
	subscriptions = []

	result =
		# send commands to redis __commands channel__
		emit: (commandName, sender, message) ->
			console.log "hub -- publishing command #{commandName} to redis:"
			console.log message
			message = JSON.stringify message, null, 4
			cmd.publish 'commands', message

		# store subscriptions for a channel (mostly __events__) in a array
		on: (channel, callback) ->
			subscriptions.push
				channel: channel
				callback: callback

			console.log "hub -- subscribers: #{subscriptions.length}"

	# listen to events from redis and call each callback from subscribers
	evt.on 'message', (channel, message) ->
		console.log "hub -- received event #{message.event} from redis:"
		message = JSON.parse message
		console.log message
		subscriptions.forEach (subscriber) ->
			subscriber.callback message if channel is subscriber.channel

	# subscribe to __events channel__
	evt.subscribe 'events'
	
	result
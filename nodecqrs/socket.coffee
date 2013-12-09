define ['odo/eventstore/hub'], (hub) ->
	init: (app) ->
		# SETUP COMMUNICATION CHANNELS

		# On receiving __commands__ from browser via socket.io emit them on the ĥub module (which will forward it to redis pubsub)
		app.io.sockets.on 'connection', (socket) ->
			conn = "#{socket.handshake.address.address}:#{socket.handshake.address.port}"
			console.log "#{conn} -- connects to socket.io"
			socket.on 'commands', (data) ->
				console.log "#{conn} -- sending command #{data.command}"
				hub.emit data.command, conn, data



		# On receiving an __event__ from redis via the hub module forward it to connected browsers via socket.io
		hub.on 'events', (data) ->
			console.log "socket.io -- publish event #{data.event} to browser"
			app.io.sockets.emit 'events', data
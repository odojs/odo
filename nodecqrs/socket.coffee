define ['socket.io', 'odo/hub'], (socket, hub) ->
	init: (app) ->
		# SETUP COMMUNICATION CHANNELS
		app.io = socket.listen app.server

		# On receiving __commands__ from browser via socket.io emit them on the ĥub module (which will forward it to redis pubsub)
		app.io.sockets.on 'connection', (socket) ->
			conn = "#{socket.handshake.address.address}:#{socket.handshake.address.port}"
			console.log "#{conn} connected to socket.io"
			socket.on 'commands', (data) ->
				console.log "#{conn} -> #{data.command}"
				hub.send data

		# On receiving an __event__ from redis via the hub module forward it to connected browsers via socket.io
		hub.eventstream (data) ->
			console.log "#{data.event} -> browser"
			app.io.sockets.emit 'events', data
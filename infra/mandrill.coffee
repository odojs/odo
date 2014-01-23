define ['q', 'mandrill-api/mandrill', 'odo/infra/config'], (Q, mandrill, config) ->
	class Mandrill
		client = new mandrill.Mandrill config.mandrill['api key']
		
		#options =
		#	message:
		#		text: 'Hello, this seems to be working'
		#		subject: 'Blackbeard test'
		#		from_email: 'blackbeard@voodoolabs.net'
		#		from_name: 'Blackbeard'
		#		to: [
		#			email: 'thomas.coats@gmail.com'
		#			name: 'Thomas Coats'
		#			type: 'to'
		#		]
		send: (options) =>
			dfd = Q.defer()
			
			client.messages.send options
			, (result) =>
				dfd.resolve result
			, (error) =>
				console.log "A mandrill error occurred: #{e.name} - #{e.message}"
				dfd.reject error
			
			dfd.promise
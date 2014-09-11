define [
	'odo/config'
	'odo/hub'
	'odo/inject'
	'odo/redis'
	'js-md5'
], (config, hub, inject, redis, md5) ->
	class UserApi
		constructor: ->
			inject.bind 'odo user by id', @get
		
		db: =>
			return @_db if @_db?
			return @_db = redis()
		
		projection: =>
			hub.every 'start tracking user {id}', (m, cb) =>
				# just in case we don't get another opportunity to grab the displayName
				user =
					id: m.id
					displayName: m.profile.displayName
				
				@db().hset "#{config.odo.domain}:users", m.id, JSON.stringify(user, null, 2), cb
			
			hub.every 'assign email address {email} to user {id}', @mutate (m, user) ->
				user.email = m.email
				user.emailHash = md5 m.email.trim().toLowerCase()
				user
			
			hub.every 'assign displayName {displayName} to user {id}', @mutate (m, user) ->
				user.displayName = m.displayName
				user
			
			hub.every 'assign username {username} to user {id}', @mutate (m, user) ->
				user.username = m.username
				user
					
			hub.every 'connect twitter to user {id}', @mutate (m, user) ->
				user.twitter =
					id: m.profile.id
					profile: m.profile
				user
				
			hub.every 'disconnect twitter from user {id}', @mutate (m, user) ->
				user.twitter = null
				user
			
			hub.every 'connect facebook to user {id}', @mutate (m, user) ->
				user.facebook =
					id: m.profile.id
					profile: m.profile
				user
				
			hub.every 'disconnect facebook from user {id}', @mutate (m, user) ->
				user.facebook = null
				user
			
			hub.every 'connect google to user {id}', @mutate (m, user) ->
				user.google =
					id: m.profile.id
					profile: m.profile
				user
				
			hub.every 'disconnect google from user {id}', @mutate (m, user) ->
				user.google = null
				user
				
			hub.every 'connect metocean to user {id}', @mutate (m, user) ->
				user.metocean =
					id: m.profile.id
					profile: m.profile
				user
				
			hub.every 'disconnect metocean from user {id}', @mutate (m, user) ->
				user.metocean = null
				user
				
			hub.every 'create local signin for user {id}', @mutate (m, user) ->
				user.local =
					id: m.id
					profile: m.profile
				user
			
			hub.every 'set password of user {id}', @mutate (m, user) ->
				user.local.profile.password = m.password
				user
			
			hub.every 'remove local signin from user {id}', @mutate (m, user) ->
				user.local = null
				user
		
		mutate: (mutate) =>
			(m, cb) =>
				@db().hget "#{config.odo.domain}:users", m.id, (err, user) =>
					throw err if err?
					user = mutate m, JSON.parse user
					@db().hset "#{config.odo.domain}:users", m.id, JSON.stringify(user, null, 2), => cb()
		
		get: (id, cb) =>
			@db().hget "#{config.odo.domain}:users", id, (err, data) =>
				throw err if err?
				data = JSON.parse data
				
				cb null, data
		

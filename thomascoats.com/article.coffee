define [], () ->
	# The itemAggregate is the aggregationRoot for a single item all commands concerning this aggregate are handled inside this object. The itemAggregate has an internal state (id, text, destoyed)

	class Item
		constructor: (id) ->
			@id = id
			@_destroy = false
			@name = ''
			@title = ''
			@content = ''
		
		createArticle: (command, callback) =>
			if !command.name? or command.name is ''
				callback new Error 'Article name needed'
				return
			
			@new 'articleCreated',
				id: @id
				name: command.name
			callback null
		
		updateArticleContent: (command, callback) =>
			if !command.content? is ''
				callback new Error 'Article content needed'
				return
				
			@new 'contentUpdated',
				id: @id,
				content: command.content
			callback null
		
		deleteArticle: (command, callback) =>
			@new 'articleDeleted',
				id: @id
			callback null
		
		_articleCreated: (event) =>
			@name = event.name
		
		_contentUpdated: (event) =>
			@content = event.content
		
		_articleDeleted: (event) =>
			@_destroy = true
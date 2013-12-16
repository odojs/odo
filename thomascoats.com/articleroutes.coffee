define ['odo/hub', 'thomascoats.com/articlecontentprojection', 'thomascoats.com/articleownershipprojection'], (hub, articlecontent, articleownership) ->
	
	init: (app) ->
		app.get '/user/:id/articles', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
				
			if req.user.id isnt req.params.id
				res.send 403, 'authentication required'
				return
				
			articleownership.get req.params.id, (err, data) ->
				if err?
					res.send 500, err
					return
					
				if !data?
					res.send 404, err
					return
				
				articles = []
				for id, name of data
					articles.push {
						id: id
						name: name
						href: "article/#{id}"
					}
					
				res.send articles
			
		app.get '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			articlecontent.get req.params.id, (err, article) ->
				if err?
					res.send 500, err
					return
				
				if !article?
					res.send 404, err
					return
						
				# make sure the person is allowed to access
				articleownership.get req.user.id, (err, articles) ->
					if err?
						res.send 500, err
						return
					
					if !articles[req.params.id]?
						res.send 403, 'authentication required'
						return
					
					res.send article
		
		app.post '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			hub.send
				command: 'createArticle'
				payload:
					id: req.params.id
					name: req.body.name
					by: req.user.id
			
			res.send 'Ok'
		
		app.delete '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			# make sure the person is allowed to access
			articleownership.get req.user.id, (err, articles) ->
				if err?
					res.send 500, err
					return
				
				if !articles[req.params.id]?
					res.send 403, 'authentication required'
					return
			
				hub.send
					command: 'deleteArticle'
					payload:
						id: req.params.id
						by: req.user.id
							
				res.send 'Ok'
			
			
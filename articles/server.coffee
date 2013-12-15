define ['module', 'path', 'express', 'redis', 'odo/hub', 'thomascoats.com/articlecontentprojection', 'thomascoats.com/articleownershipprojection'], (module, path, express, redis, hub, articlecontent, articleownership) ->
	
	configure: (app) ->
		app.use('/articles', express.static(path.dirname(module.uri) + '/public'))
	
	init: (app) ->
		app.get '/user/:id/articles', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
				
			if req.user.id isnt req.params.id
				res.send 403, 'authentication required'
				return
				
			articleownership.get req.params.id, (err, articles) ->
				console.log 'Loaded articleownership projection'
				console.log articles
			
				
			client = redis.createClient()
			
			client.smembers "user:#{req.params.id}:articles", (err, articles) ->
				if err?
					res.send 500, err
					client.quit()
					return
				
				client.quit()
				articles = articles.map (article) ->
					article = JSON.parse article
					article.href = "article/#{article.id}"
					if !article.name?
						article.name = article.title
					article
				res.send articles
			
		app.get '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			articlecontent.get req.params.id, (err, article) ->
				console.log 'Loaded articlecontent projection'
				console.log article
				
			client = redis.createClient()
			
			client.get "article:#{req.params.id}", (err, article) ->
				if err?
					res.send 500, err
					client.quit()
					return
				
				if !article?
					res.send 404
					client.quit()
					return
				
				client.quit()
				
				article = JSON.parse article
				
				if !article.name
					article.name = article.title
				
				if req.user.id isnt article.userid
					res.send 403, 'authentication required'
					return
				
				res.send article
		
		app.post '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
				
			article = req.body
			article.userid = req.user.id
			
			console.log 'Sending createArticle'
			hub.send
				command: 'createArticle'
				payload:
					id: req.params.id
					name: req.body.name
					by: req.user.id
					
			client = redis.createClient()
			
			client.multi()
				.set("article:#{req.params.id}", JSON.stringify(article))
				.sadd("user:#{req.user.id}:articles", JSON.stringify({
					id: article.id
					href: "article/#{article.id}",
					name: article.name
				}))
				.exec (err) ->
					if err?
						res.send 500, err
						client.quit()
						return
					
					client.quit()
					
					res.send 'Ok'
		
		app.delete '/article/:id', (req, res) ->
			if !req.user?
				res.send 403, 'authentication required'
				return
			
			console.log 'Sending deleteArticle'
			hub.send
				command: 'deleteArticle'
				payload:
					id: req.params.id
					by: req.user.id
			
			client = redis.createClient()
			
			client.get "article:#{req.params.id}", (err, article) ->
				if err?
					res.send 500, err
					client.quit()
					return
				
				if !article?
					res.send 404
					client.quit()
					return
			
				client.multi()
					.del("article:#{req.params.id}")
					.srem("user:#{article.userid}:articles", JSON.stringify({
							id: article.id
							href: "article/#{article.id}",
							name: article.name
						}))
					
					.exec (err) ->
						if err?
							res.send 500, err
							client.quit()
							return
						
						client.quit()
						
						res.send 'Ok'
			
			
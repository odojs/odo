// Generated by CoffeeScript 1.6.3
(function() {
  define(['module', 'path', 'express', 'redis', 'odo/hub', 'thomascoats.com/articlecontentprojection', 'thomascoats.com/articleownershipprojection'], function(module, path, express, redis, hub, articlecontent, articleownership) {
    return {
      configure: function(app) {
        return app.use('/articles', express["static"](path.dirname(module.uri) + '/public'));
      },
      init: function(app) {
        app.get('/user/:id/articles', function(req, res) {
          var client;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          if (req.user.id !== req.params.id) {
            res.send(403, 'authentication required');
            return;
          }
          articleownership.get(req.params.id, function(err, articles) {
            console.log('Loaded articleownership projection');
            return console.log(articles);
          });
          client = redis.createClient();
          return client.smembers("user:" + req.params.id + ":articles", function(err, articles) {
            if (err != null) {
              res.send(500, err);
              client.quit();
              return;
            }
            client.quit();
            articles = articles.map(function(article) {
              article = JSON.parse(article);
              article.href = "article/" + article.id;
              if (article.name == null) {
                article.name = article.title;
              }
              return article;
            });
            return res.send(articles);
          });
        });
        app.get('/article/:id', function(req, res) {
          var client;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          articlecontent.get(req.params.id, function(err, article) {
            console.log('Loaded articlecontent projection');
            return console.log(article);
          });
          client = redis.createClient();
          return client.get("article:" + req.params.id, function(err, article) {
            if (err != null) {
              res.send(500, err);
              client.quit();
              return;
            }
            if (article == null) {
              res.send(404);
              client.quit();
              return;
            }
            client.quit();
            article = JSON.parse(article);
            if (!article.name) {
              article.name = article.title;
            }
            if (req.user.id !== article.userid) {
              res.send(403, 'authentication required');
              return;
            }
            return res.send(article);
          });
        });
        app.post('/article/:id', function(req, res) {
          var article, client;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          article = req.body;
          article.userid = req.user.id;
          console.log('Sending createArticle');
          hub.send({
            command: 'createArticle',
            payload: {
              id: req.params.id,
              name: req.body.name,
              by: req.user.id
            }
          });
          client = redis.createClient();
          return client.multi().set("article:" + req.params.id, JSON.stringify(article)).sadd("user:" + req.user.id + ":articles", JSON.stringify({
            id: article.id,
            href: "article/" + article.id,
            name: article.name
          })).exec(function(err) {
            if (err != null) {
              res.send(500, err);
              client.quit();
              return;
            }
            client.quit();
            return res.send('Ok');
          });
        });
        return app["delete"]('/article/:id', function(req, res) {
          var client;
          if (req.user == null) {
            res.send(403, 'authentication required');
            return;
          }
          console.log('Sending deleteArticle');
          hub.send({
            command: 'deleteArticle',
            payload: {
              id: req.params.id,
              by: req.user.id
            }
          });
          client = redis.createClient();
          return client.get("article:" + req.params.id, function(err, article) {
            if (err != null) {
              res.send(500, err);
              client.quit();
              return;
            }
            if (article == null) {
              res.send(404);
              client.quit();
              return;
            }
            return client.multi().del("article:" + req.params.id).srem("user:" + article.userid + ":articles", JSON.stringify({
              id: article.id,
              href: "article/" + article.id,
              name: article.name
            })).exec(function(err) {
              if (err != null) {
                res.send(500, err);
                client.quit();
                return;
              }
              client.quit();
              return res.send('Ok');
            });
          });
        });
      }
    };
  });

}).call(this);

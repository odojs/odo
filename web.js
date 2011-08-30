var express = require('express');
var redis = require('redis-url');
var app = express.createServer(express.logger());

var redis_url = process.env.REDISTOGO_URL || 'localhost:6379';
var rtg = require('url').parse(redis_url);


app.get('/', function(request, response) {
    var client = redis.createClient(rtg.port, rtg.hostname);
    client.set('foo', 'bar');
    client.get('foo', function(err, value) {
        response.send('foo is: ' + value);
    });
});

var port = process.env.PORT || 3000;
app.listen(port, function() {
    console.log("Listening on " + port);
});
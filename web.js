var express = require('express');
var app = express.createServer(express.logger());


app.get('/', function(request, response) {
    if (process.env.REDISTOGO_URL) {
        var rtg   = require('url').parse(process.env.REDISTOGO_URL);
        var redis = require('redis').createClient(rtg.port, rtg.hostname);
        redis.auth(rtg.auth.split(':')[1]);
    } else {
        var redis = require('redis').createClient();
    }

    redis.set('foo', 'bar');
    redis.get('foo', function(err, value) {
        response.send('foo is: ' + value);
        redis.end()
    });
});

var port = process.env.PORT || 3000;
app.listen(port, function() {
    console.log("Listening on " + port);
});
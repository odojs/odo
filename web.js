var express = require('express');
var redis = require('redis-url');

var app = express.createServer(express.logger());

app.get('/', function(request, response) {
    var client = redis.createClient(process.env.REDISTOGO_URL);
    client.set('foo', 'bar');
    client.get('foo', function(err, value) {
        response.send('foo is: ' + value);
    });
});

var port = process.env.PORT || 3000;
app.listen(port, function() {
    console.log("Listening on " + port);
});
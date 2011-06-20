var redis = require('redis');

app.get('/services/store', function(req, res, next) {
    if (!req.query.key) {
        next();
        return;
    }
    
    var client = redis.createClient();
    
    client.on('error', function (err) {
        console.log('Redis connection error to ' + client.host + ':' + client.port + ' - ' + err);
    });
    
    
    //client.set('recipies', '{"a":"b"}', redis.print);
    
    client.get(req.query.key, function (err, value) {
        client.end();
        
        if (err) {
            next(err);
            return;
        }
        
        var data = null;
        try {
            data = JSON.parse(value);
        } catch (err) {
            client.end();
            next(err);
            return;
        }
        
        //console.log('get:' + req.query.key + ':' + JSON.stringify(data));
        res.send(data);
    });
});

app.post('/services/store', function(req, res, next) {
    if (!req.query.key) {
        next();
        return;
    }
    
    var value = '';
    req.setEncoding('utf8');
    req.on('data', function(chunk) { value += chunk; });
    req.on('end', function() {
        var data = null;
        try {
            data = JSON.parse(value);
        } catch (err) {
            next(err);
            return;
        }
        
        var client = redis.createClient();
    
        client.on('error', function (err) {
            console.log('Redis connection error to ' + client.host + ':' + client.port + ' - ' + err);
        });
        
        //console.log('set:' + req.query.key + ':' + JSON.stringify(data));
        client.set(req.query.key, JSON.stringify(data), function (err, reply) {
            client.end();
        });
    });
});
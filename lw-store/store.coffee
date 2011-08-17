redis = require 'redis'
path = require 'path'
inject = require 'pminject'

inject.bind routes:
    from: '/'
    to: path.normalize(__dirname + '/www/')

app = inject.one 'app'

app.get '/examples/store', (req, res, next) =>
    if not req.query.key
        next()
        return
    
    client = redis.createClient()
    
    client.on 'error', (err) =>
        console.log 'Redis connection error to ' + client.host + ':' + client.port + ' - ' + err
    
    client.get req.query.key, (err, value) =>
        client.end()
        
        if err
            next(err)
            return
        
        data = null;
        try
            data = JSON.parse value
        catch err
            client.end()
            next(err)
            return
        
        #console.log 'get:' + req.query.key + ':' + JSON.stringify(data)
        res.send data

app.post '/examples/store', (req, res, next) =>
    if not req.query.key
        next()
        return
    
    value = ''
    req.setEncoding 'utf8'
    req.on 'data', (chunk) => value += chunk
    req.on 'end', () =>
        data = null;
        try
            data = JSON.parse value
        catch err
            next(err)
            return
        
        client = redis.createClient();
    
        client.on 'error', (err) =>
            console.log 'Redis connection error to ' + client.host + ':' + client.port + ' - ' + err
        
        #console.log 'set:' + req.query.key + ':' + JSON.stringify(data)
        client.set req.query.key, JSON.stringify(data), (err, reply) =>
            client.end()
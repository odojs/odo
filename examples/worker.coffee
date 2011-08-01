redis = require 'redis'
app = require '../core/app'

client1 = redis.createClient()
client1.on 'ready', =>
    client1.subscribe 'info'
    client1.on 'message', (channel, message) =>
        console.log JSON.parse message

app.get '/examples/worker', (req, res, next) =>
    client2 = redis.createClient()
    client2.on 'ready', =>
        client2.publish 'info', JSON.stringify
            info: 'I am sending a message.'
        client2.end()
        res.send 'It is done'
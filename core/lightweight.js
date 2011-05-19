var http = require('http');
var store = require('supermarket');
var paperboy = require('paperboy');

//todo: upload files

var server = http.createServer(function(req, res) {
    console.log(__dirname + '/../www/');
    paperboy
        .deliver(__dirname + '/../www/', req, res)
        .before(function() {
            console.log('About to deliver: ' + req.url);
        })
        .after(function() {
            console.log('Delivered: ' + req.url);
        })
        .error(function(statusCode) {
            console.log('Error delivering: ' + req.url + ' ' + statusCode);
            res.writeHead(statusCode, {'Content-Type': 'text/plain'});
            res.write('Error delivering: ' + req.url + ' status: ' + statusCode);
            res.end();
        })
        .otherwise(function() {
            var url = require('url').parse(req.url, true);
            
            switch (url.pathname) {
                case '/services/store':
                    require('./store').request(url, req, res);
                    break;
                case '/services/list':
                    require('./list').request(url, req, res);
                    break;
                default:
                    res.writeHead(404, {'Content-Type': 'text/plain'});
                    res.write('Not Found');
                    res.end();
                    break;
        
            }
        });
});
server.listen(3000);

console.log('Server running at http://localhost:3000/');
var http = require('http');
var store = require('supermarket');
var paperboy = require('paperboy');
var path = require('path');

//todo: upload files

var server = http.createServer(function(req, res) {
    var url = require('url').parse(req.url, true);
    url.www = path.normalize(__dirname + '/../www/');
    paperboy
        .deliver(url.www, req, res)
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
            if (require('./services/store.js').request(url, req, res)) return;
            if (require('./services/list.js').request(url, req, res)) return;
            if (require('./services/upload.js').request(url, req, res)) return;
            
            res.writeHead(404, {'Content-Type': 'text/plain'});
            res.write('Not Found');
            res.end();
        });
});
server.listen(80);

console.log('Server running at http://localhost/');
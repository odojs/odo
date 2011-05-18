var http = require('http');
var store = require('supermarket');
var paperboy = require('paperboy');
var path = require('path');
var fs = require('fs');

//todo: upload files

var server = http.createServer(function(req, res) {
    paperboy
        .deliver(path.dirname(__filename), req, res)
        .before(function() {
            console.log('About to deliver: ' + req.url);
        })
        .after(function() {
            console.log('Delivered: ' + req.url);
        })
        .error(function() {
            console.log('Error delivering: ' + req.url);
        })
        .otherwise(function() {
            var url = require('url').parse(req.url, true);
            var data = '';
            
            switch (url.pathname) {
                case '/services/store':
                    if (!url.query.key) {
                        res.writeHead(404, {'Content-Type': 'text/plain'});
                        res.write('Not Found');
                        res.end();
                        break;
                    }
                    
                    if (req.method == 'GET') {
                        res.writeHead(200, {'Content-Type': 'application/json'});
                        
                        store('store.db', function (err, db) {
                            db.get(url.query.key, function (error, value, key) {
                                res.end(value);
                            });
                        });
                    } else if (req.method == 'POST') {
                        req
                            .on('data', function(chunk) {
                                data += chunk;
                            })
                            .on('end', function(){
                                console.log(data);
                                
                                store('store.db', function (err, db) {
                                    if (err) {
                                        res.writeHead(500, {'Content-Type': 'text/plain'});
                                        res.write('Could not open database');
                                        res.end();
                                        console.error(err.stack);
                                        
                                        return;
                                    }
                                    db.set(url.query.key, data);
                                });
                                
                                res.writeHead(200, {'Content-Type': 'text/plain'});
                                res.write('OK');
                                res.end();
                            });
                    } else {
                        res.writeHead(405, {'Content-Type': 'text/plain'});
                        res.write('Method Not Allowed');
                        res.end();
                    }
                    
                    break;
                case '/services/list':
                    if (!url.query.dir) {
                        res.writeHead(404, {'Content-Type': 'text/plain'});
                        res.write('Not Found');
                        res.end();
                        break;
                    }
                    
                    var dirpath = path.dirname(__filename) + '/' + url.query.dir;
                        
                    fs.readdir(dirpath, function(err, files) {
                        if (err) {
                            res.writeHead(500, {'Content-Type': 'text/plain'});
                            res.write('Could not list dir');
                            res.end();
                            console.error(err.stack);
                            
                            return;
                        }
                        
                        files = files.map(function (file) {
                            var path = dirpath + '/' + file;
                            var index = file.indexOf('.');
                            if (index < 0)
                                index = file.length;
                            return {
                                path: path,
                                filename: file,
                                ext: file.substr(index),
                                stat: fs.statSync(path)
                            };
                        });
                        
                        if (url.query.ext)
                            files = files.filter(function (file) {
                                return file.ext == url.query.ext;
                            });
                        
                        if (url.query.type == 'file')
                            files = files.filter(function (file) {
                                return file.stat.isFile();
                            });
                        
                        if (url.query.type == 'dir')
                            files = files.filter(function (file) {
                                return file.stat.isDirectory();
                            });
                        
                        files = files.map(function (file) {
                            return {
                                name: file.filename,
                                ext: file.ext,
                                isDir: file.stat.isDirectory()
                            };
                        });
                        
                        res.writeHead(200, {'Content-Type': 'application/json'});
                        res.write(JSON.stringify(files));
                        res.end();
                    });
                    
                    break;
                default:
                    res.writeHead(404, {'Content-Type': 'text/plain'});
                    res.write('Not Found');
                    res.end();
                    break;
        
            }
        });
});
server.listen(1337, '127.0.0.1');

console.log('Server running at http://127.0.0.1:1337/');
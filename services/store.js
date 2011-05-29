var store = require('supermarket');

this.request = function(url, req, res) {
    var match = new RegExp('/services/store').exec(url.pathname);
    if (!match)
        return false;
        
    if (!url.query.db || !url.query.key) {
        res.writeHead(404, {'Content-Type': 'text/plain'});
        res.write('Not Found');
        res.end();
        return true;
    }
    
    if (req.method == 'GET') {
        res.writeHead(200, {'Content-Type': 'application/json'});
        
        store('../../store/' + url.query.db + '.db', function (err, db) {
            db.get(url.query.key, function (error, value, key) {
                res.end(value);
            });
        });
        return true;
    }
    
    if (req.method == 'POST') {
        var data = '';
        req
            .on('data', function(chunk) {
                data += chunk;
            })
            .on('end', function(){
                console.log(data);
                
                store('../../store/' + url.query.db + '.db', function (err, db) {
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
        return true;
    }
    
    res.writeHead(405, {'Content-Type': 'text/plain'});
    res.write('Method Not Allowed');
    res.end();
    return true;
}
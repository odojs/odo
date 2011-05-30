var store = require('supermarket');


app.get('/services/store', function(req, res, next) {
    if (!req.query.db || !req.query.key) {
        next();
        return;
    }
    
    store({
        filename: app.set('store') + req.query.db + '.db',
        json: true
    },
    function (err, db) {
        if (err) {
            next(err);
            return;
        }
        db.get(req.query.key, function (err, value, key) {
            if (err) {
                next(err);
                return;
            }
            res.send(value);
        });
    });
});

app.post('/services/store', function(req, res, next) {
    if (!req.query.db || !req.query.key) {
        next();
        return;
    }
    
    var data = '';
    req.setEncoding('utf8');
    req.on('data', function(chunk) { data += chunk; });
    req.on('end', function() {
        store({
            filename: app.set('store') + req.query.db + '.db',
            json: true
        }, function (err, db) {
            if (err) {
                next(err);
                return;
            }
            console.log(data);
            db.set(req.query.key, JSON.parse(data), function (err) {
                if (err) {
                    next(err);
                    return;
                }
            });
        });
        
        res.send('OK');
    });
});
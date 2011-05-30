var express = require('express');
var path = require('path');
app = express.createServer();

require('../services/list.js');
require('../services/store.js');
require('../services/upload.js');

app.configure(function() {
    app.set('www', path.normalize(__dirname + '/../www/'));
    app.set('upload', path.normalize(__dirname + '/../www/upload/'));
    app.set('store', path.normalize(__dirname + '/../store/'));
    
    //app.use(express.logger());
    app.use(express.bodyParser());
    //app.use(express.methodOverride());
    //app.use(express.cookieParser());
    //app.use(express.session({ secret: "bob" }));
    app.use(app.router);
    app.use(express.static(app.set('www')));
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.listen(80);

console.log('Server running at http://localhost/');
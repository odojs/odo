var express = require('express');
var path = require('path');

app.configure(function() {
    app.set('www', path.normalize(__dirname + '/../www/'));
    app.set('upload', path.normalize(__dirname + '/../www/upload/'));
    app.set('store', path.normalize(__dirname + '/../store/'));
    //app.set('wiki', path.normalize(__dirname + '/../../VoodooLabs/Voodoo/Voodoo.Web.App/wiki/'));
    app.set('wiki', path.normalize(__dirname + '/../www/wiki/'));
    
    //app.use(express.logger());
    //app.use(express.bodyParser());
    //app.use(express.methodOverride());
    //app.use(express.cookieParser());
    //app.use(express.session({ secret: "bob" }));
    app.use(app.router);
    app.use(require('./static.js')('/', app.set('www')));
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});
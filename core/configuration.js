var express = require('express');
var path = require('path');
var less = require('./less');
var nun = require('./nun');
var static = require('./static');
var route = require('./route');
var view = require('./view');

app.configure(function() {
    app.set('www', path.normalize(__dirname + '/../www/'));
    app.set('upload', path.normalize(__dirname + '/../www/upload/'));
    app.set('wiki', path.normalize(__dirname + '/../www/wiki/'));
    app.set('views', path.normalize(__dirname + '/../www/'));
    
    //app.use(express.logger());
    //app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(express.session({ secret: "bob" }));
    app.use(view());
    app.use(app.router);
    app.use(route('/', app.set('www'), less()));
    app.use(route('/', app.set('www'), nun()));
    app.use(route('/', app.set('www'), static()));
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});
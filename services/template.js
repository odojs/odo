var nun = require("nun");

app.get('/test', function(req, res, next) {
    var origin = app.set('www') + "template.html";
    nun.render(origin, { name: "John Dow" }, {}, function(err, output) {
        if (err) {
            next(err);
            return;
        }
    
        var buffer = '';
        output
            .on('data', function(data) { buffer += data; })
            .on('end', function() { res.send(buffer) });
    });
});

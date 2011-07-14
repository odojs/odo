app.get('/', function(req, res, next) {
    req.model = (req.model || {}).extend({
        name: 'John Dow'
    });
    next();
});

var paperboy = require('paperboy');

exports = module.exports = function static(options) {
    options = options || {};
    return function(req, res, next, route) {
        paperboy
            .deliver(route.map, req.extend({ url: route.url }), res)
            .otherwise(function () {
                next();
            });
    };
};
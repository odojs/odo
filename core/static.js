var paperboy = require('paperboy');

exports = module.exports = function static(options) {
    options = options || {};
    return function(req, res, next) {
        paperboy
            .deliver(req.route.map, req, res)
            .otherwise(function () {
                next();
            });
    };
};
paperboy = require 'paperboy'

module.exports = (options) =>
    options = options || {}
    return (req, res, next) =>
        paperboy.deliver(req.route.map, req, res).otherwise(() => next())
_ = require 'underscore'
os = require 'os'
moment = require 'moment'

bytesToSize = (bytes, precision = 0) ->
	kilobyte = 1024
	megabyte = kilobyte * 1024
	gigabyte = megabyte * 1024
	terabyte = gigabyte * 1024

	if bytes >= 0 and bytes < kilobyte
	    return bytes + ' B'

	if bytes >= kilobyte and bytes < megabyte
	    return (bytes / kilobyte).toFixed(precision) + ' KB'

	if bytes >= megabyte and bytes < gigabyte
	    return (bytes / megabyte).toFixed(precision) + ' MB';

	if bytes >= gigabyte and bytes < terabyte
	    return (bytes / gigabyte).toFixed(precision) + ' GB';

	if bytes >= terabyte
	    return (bytes / terabyte).toFixed(precision) + ' TB';

	bytes + ' B'

module.exports =
	init: (app) ->
		app.get '/%CF%88/server/', (req, res) ->
			settings = {
				'Environment': app.get 'env'
				'Request host': req.headers.host
				'Server name': os.hostname()
				'Operating system': "#{os.type()} #{os.arch()} (#{os.release()})"
				'Last restarted': moment().subtract('seconds', os.uptime()).fromNow()
				'Memory': "#{bytesToSize(os.freemem())} free / #{bytesToSize(os.totalmem())} available"
				'CPUs': os.cpus().length
			}

			settings = _(settings).pairs().map (pair) ->
				{
					key: pair[0]
					value: pair[1]
				}

			res.render
				view: 'admin/layout'
				data:
					title: 'Ψ -> Server information'
					bodyclasses: ['prompt']
					settings: settings
				partials:
					content: 'server/server'

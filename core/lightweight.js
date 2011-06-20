app = require('express').createServer();

require('./util.js');
require('./configuration.js');
require('../services/list.js');
require('../services/store.js');
require('../services/upload.js');

app.listen(3000);
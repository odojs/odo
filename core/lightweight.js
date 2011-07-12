app = require('express').createServer();

require('./util.js');
require('./configuration.js');
require('../services/list.js');
require('../services/store.js');
require('../services/upload.js');
require('../services/template.js');

app.listen(3000);
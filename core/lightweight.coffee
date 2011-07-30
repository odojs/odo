app = require './app'

require './underscore'
require './configuration'
require '../services/list'
require '../services/wiki'
require '../services/store'
require '../services/upload'
require '../services/template'

app.listen 3000
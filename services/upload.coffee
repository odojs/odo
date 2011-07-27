formidable = require 'formidable'
app = require '../core/app'

status = {};

# parse an upload using formidable.
app.post '/services/upload/:uuid', (req, res, next) =>
    uuid = req.params.uuid
    status[uuid] =
        filename: ''
        mime: ''
        metadata: {}
        progress:
            received: 0
            expected: 0
            percent: 0
    
    console.log 'receiving upload: ' + uuid
    
    form = new formidable.IncomingForm()
    form.uploadDir = app.set 'upload'
    form.keepExtensions = true
    
    # keep track of progress.
    form.addListener 'progress', (received, expected) =>
        status[uuid].progress =
            received: received
            expected: expected
            percent: (received / expected * 100).toFixed 2
    
    form.parse req, (error, fields, files) =>
        if error
            next(error)
            return
        status[uuid].savedfilename = files['file']['path'].substr app.set('upload').length
        status[uuid].filename = files['file']['filename']
        status[uuid].mime = files['file']['mime']
        res.send 'OK'
        console.log 'finished upload: ' + uuid


app.post '/services/update/:uuid', (req, res, next) =>
    uuid = req.params.uuid;
    form = new formidable.IncomingForm()
    form.addListener 'field', (name, value) =>
        console.log('fresh metadata for ' + uuid + ': ' + name + ' => ' + value)
        status[uuid].metadata[name] = value
    form.parse req


app.get '/services/progress/:uuid', (req, res, next) =>
    uuid = req.params.uuid;
    if status[uuid]
        res.send status[uuid]
    else
        res.send
            filename: ''
            mime: ''
            metadata: {}
            progress:
                received: 0
                expected: 0
                percent: 0

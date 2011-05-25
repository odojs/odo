var formidable = require('formidable');

var status = {};

this.request = function (url, req, res) {
    var match = null;

    // parse an upload using formidable.
    match = new RegExp('/upload/(.+)').exec(url.pathname);
    if (match && req.method.toLowerCase() == 'post') {
        var uuid = match[1];
        status[uuid] = {
            filename: '',
            mime: '',
            metadata: {},
            progress: {
                received: 0,
                expected: 0,
                percent: 0
            }
        };
        console.log("receiving upload: "+uuid+'\n');
        
        var form = new formidable.IncomingForm();
        form.uploadDir = url.upload;
        form.keepExtensions = true;
        
        // keep track of progress.
        form.addListener('progress', function(received, expected) {
            status[uuid].progress = {
                received: received,
                expected: expected,
                percent: (received / expected * 100).toFixed(2)
            }
        });
        
        form.parse(req, function(error, fields, files) {
            if (error) {
                console.log(JSON.stringify(error));
                res.writeHead(500, {'Content-Type': 'text/plain'});
                res.write(error.message + ':\n' + error.stack);
                res.end();
                return;
            }
            status[uuid].savedfilename = files['file']['path'].substr(url.upload.length);
            status[uuid].filename = files['file']['filename'];
            status[uuid].mime = files['file']['mime'];
            res.writeHead(200, {'content-type': 'text/plain'});
            res.write('OK')
            res.end()
            console.log("finished upload: "+uuid+'\n');
        });
        return true;
    }
    
    // (update) metadata
    //match = new RegExp('/update/(.+)').exec(url.pathname);
    //if (match && req.method.toLowerCase() == 'post') {
    //    uuid = match[1]
    //    var form = new formidable.IncomingForm();
    //    form.addListener('field', function(name, value) {
    //        console.log("fresh metadata for "+uuid+": "+name+" => "+value+"\n")
    //        status[uuid].metadata[name] = value;
    //    });
    //    form.parse(req);
    //    return true;
    //}
    
    // respond to progress queries.
    match = new RegExp('/progress/(.+)').exec(url.pathname);
    if (match) {
        uuid = match[1];
        res.writeHead(200, {'content-type': 'application/json'});
        if (status[uuid])
            res.write(JSON.stringify(status[uuid]));
        else
            res.write(JSON.stringify({
                filename: '',
                mime: '',
                metadata: {},
                progress: {
                    received: 0,
                    expected: 0,
                    percent: 0
                }
            }));
        res.end();
        return true;
    }
    
    return false;
}
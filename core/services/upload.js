var formidable = require('formidable');

var progresses = {}
var metadata   = {}

this.request = function (url, req, res) {
    var match = null;

    // parse an upload using formidable.
    match = new RegExp('/upload/(.+)').exec(url.pathname);
    if (match && req.method.toLowerCase() == 'post') {
        var uuid = match[1];
        console.log("receiving upload: "+uuid+'\n');
        
        var form = new formidable.IncomingForm();
        form.uploadDir = url.upload;
        form.keepExtensions = true;
        
        // keep track of progress.
        form.addListener('progress', function(recvd, expected) {
            progress = (recvd / expected * 100).toFixed(2);
            progresses[uuid] = progress
        });
        
        form.parse(req, function(error, fields, files) {
            if (error) {
                console.log(JSON.stringify(error));
                res.writeHead(500, {'Content-Type': 'text/plain'});
                res.write(error.message + ':\n' + error.stack);
                res.end();
                return;
            }
            var path = files['file']['path'];
            var filename = files['file']['filename'];
            var mime = files['file']['mime'];
            res.writeHead(200, {'content-type': 'text/html'});
            res.write('<textarea>');
            res.write("upload complete.\n");
            res.write(filename + ' landed safely at ' + path + '\n');
            res.write('</textarea>')
            res.end()
            console.log("finished upload: "+uuid+'\n');
        });
        return true;
    }
    
    // (update) metadata
    match = new RegExp('/update/(.+)').exec(url.pathname);
    if (match && req.method.toLowerCase() == 'post') {
        uuid = match[1]
        var form = new formidable.IncomingForm();
        form.addListener('field', function(name, value) {
            console.log("fresh metadata for "+uuid+": "+name+" => "+value+"\n")
            metadata[name] = value;
        });
        form.parse(req);
    }
    
    // respond to progress queries.
    match = new RegExp('/progress/(.+)').exec(url.pathname);
    if (match) {
        uuid = match[1];
        res.writeHead(200, {'content-type': 'application/json'});
        res.write(JSON.stringify({'progress': progresses[uuid]}));
        res.end();
    }
    
    return false;
}
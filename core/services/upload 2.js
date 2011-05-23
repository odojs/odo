var formidable = require('formidable');

this.request = function(url, req, res) {
    if (req.method == 'POST') {
        res.writeHead(200, {'Content-Type': 'application/json'});
        
        var form = new formidable.IncomingForm();
        form.parse(req);
        form.on('progress', function(bytesReceived, bytesExpected) {
            var progress = {
                type: 'progress',
                bytesReceived: bytesReceived,
                bytesExpected: bytesExpected
            };
            
            socket.broadcast(JSON.stringify(progress));
        });
        form.on('file', function(field, file) {
            // file looks like this:
            // {path: '...' , filename: '...', mime: '...'}
        });
        form.on('end', function(fields, files) {
            res.writeHead(200, {'content-type': 'text/plain'});
            res.write('OK');
            console.log(sys.inspect({fields: fields, files: files}));
        });
        return;
    } else {
        res.writeHead(405, {'Content-Type': 'text/plain'});
        res.write('Method Not Allowed');
        res.end();
    }
}
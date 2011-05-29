var fs = require('fs');

this.request = function (url, req, res) {
    var match = new RegExp('/services/list').exec(url.pathname);
    if (!match)
        return false;
        
    if (!url.query.dir) {
        res.writeHead(404, {'Content-Type': 'text/plain'});
        res.write('Not Found');
        res.end();
        return true;
    }
    
    var dirpath = url.www + url.query.dir;
        
    fs.readdir(dirpath, function(err, files) {
        if (err) {
            res.writeHead(500, {'Content-Type': 'text/plain'});
            res.write('Could not list dir');
            res.end();
            console.error(err.stack + ' ' + dirpath);
            
            return;
        }
        
        files = files.map(function (file) {
            var path = dirpath + '/' + file;
            var index = file.indexOf('.');
            if (index < 0)
                index = file.length;
            return {
                path: path,
                filename: file,
                ext: file.substr(index),
                stat: fs.statSync(path)
            };
        });
        
        // don't show files starting with a dot (system files)
        files = files.filter(function (file) {
            return file.filename[0] != '.';
        });
        
        if (url.query.ext)
            files = files.filter(function (file) {
                return file.ext == url.query.ext;
            });
        
        if (url.query.type == 'file')
            files = files.filter(function (file) {
                return file.stat.isFile();
            });
        
        if (url.query.type == 'dir')
            files = files.filter(function (file) {
                return file.stat.isDirectory();
            });
        
        files = files.map(function (file) {
            return {
                name: file.filename,
                ext: file.ext,
                isDir: file.stat.isDirectory()
            };
        });
        
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.write(JSON.stringify(files));
        res.end();
    });
    
    return true;
}
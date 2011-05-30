var fs = require('fs');

app.get('/services/list', function(req, res, next) {
    if (!req.query.dir) {
        next();
        return;
    }
    
    var dirpath = app.set('www') + req.query.dir;
        
    fs.readdir(dirpath, function(err, files) {
        if (err) {
            next(err);
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
        
        if (req.query.ext)
            files = files.filter(function (file) {
                return file.ext == req.query.ext;
            });
        
        if (req.query.type == 'file')
            files = files.filter(function (file) {
                return file.stat.isFile();
            });
        
        if (req.query.type == 'dir')
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
        
        res.send(files);
    });
});
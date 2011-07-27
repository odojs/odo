fs = require('fs');
app = require '../core/app'

app.get '/services/list', (req, res, next) =>
    if not req.query.dir?
        next()
        return
    
    dirpath = (app.set 'www') + req.query.dir
        
    fs.readdir dirpath, (err, files) =>
        if err
            next(err)
            return
        
        files = files.map (file) =>
            path = dirpath + '/' + file
            index = file.indexOf '.'
            if (index < 0)
                index = file.length
            return {
                path: path
                filename: file
                ext: file.substr(index)
                stat: fs.statSync(path)
            }
        
        # don't show files starting with a dot (system files)
        files = files.filter (file) =>
            return file.filename[0] != '.'
        
        if req.query.ext
            files = files.filter (file) =>
                return file.ext == req.query.ext
        
        if req.query.type == 'file'
            files = files.filter (file) =>
                return file.stat.isFile()
        
        if req.query.type == 'dir'
            files = files.filter (file) =>
                return file.stat.isDirectory()
        
        files = files.map (file) =>
            return {
                name: file.filename
                ext: file.ext
                isDir: file.stat.isDirectory()
            }
        
        res.send files
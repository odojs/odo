fs = require('fs');

# options =
#     type = 'file' || 'dir'
#     ext = '.txt'
module.exports = (dir, options, callback) =>
    fs.readdir dir, (err, files) =>
        if err?
            callback(err, null)
            return
        
        files = files.map (file) =>
            path = dir + '/' + file
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
        
        if options.ext?
            files = files.filter (file) =>
                return file.ext == options.ext
        
        if options.type == 'file'
            files = files.filter (file) =>
                return file.stat.isFile()
        
        if options.type == 'dir'
            files = files.filter (file) =>
                return file.stat.isDirectory()
        
        callback(null, files.map (file) =>
            return {
                name: file.filename
                ext: file.ext
                isDir: file.stat.isDirectory()
            })
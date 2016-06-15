var fs = require('fs');

module.exports = function(Media) {
  Media.disableRemoteMethod("confirm", true);
  Media.disableRemoteMethod("exists", true);

  Media.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream

  Media.download = function(id, filter, cb) {
    Media.findById(id, filter, function(err, foundMedia) {
      cb(null, foundMedia.data, 'image/jpeg');
    });
  };

  Media.upload = function(id, req, cb) {
    var files = req['files'];
    if (files == undefined || files.length == 0) {
      cb('No file was uploaded');
    }
    var filename = files[0].path;

    fs.readFile(filename, function (err, data) {
      if (err) {
        cb(err);
        return;
      }

      Media.findById(id, function(err, foundMedia) {
        foundMedia.updateAttribute("data", data, function(err, updateMedia) {
          cb(err, updateMedia.id);
        });
      });
    });
  };

  Media.remoteMethod('upload', {
    isStatic: true,
    accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'req', type: 'object', 'http': { source: 'req' } }
    ],
    returns: [
      { arg: 'id', type: 'string' }
    ],
    http: { path: '/upload/:id', verb: 'post' }
  });

  Media.remoteMethod('download', {
    isStatic: true,
    accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'filter', type: 'object', 'http': { source: 'query' } }
    ],
    returns: [
      { arg: 'body', type: 'file', root: true },
      { arg: 'Content-Type', type: 'string', http: { target: 'header' } },
    ],
    http: { path: '/download/:id', verb: 'get' }
  });
};

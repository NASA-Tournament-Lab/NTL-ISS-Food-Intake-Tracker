module.exports = function(Media) {
  Media.disableRemoteMethod("confirm", true);
  Media.disableRemoteMethod("exists", true);

  Media.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

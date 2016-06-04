module.exports = function(NasaUser) {
  NasaUser.disableRemoteMethod("confirm", true);
  NasaUser.disableRemoteMethod("exists", true);

  NasaUser.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

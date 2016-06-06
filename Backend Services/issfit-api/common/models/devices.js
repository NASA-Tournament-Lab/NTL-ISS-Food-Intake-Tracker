module.exports = function(Devices) {
  Devices.disableRemoteMethod("findOne", true);

  Devices.disableRemoteMethod("confirm", true);
  Devices.disableRemoteMethod("count", true);
  Devices.disableRemoteMethod("exists", true);

  Devices.disableRemoteMethod('upsert', true);                // Removes (PUT) /products
  Devices.disableRemoteMethod('deleteById', true);            // Removes (DELETE) /products/:id
  Devices.disableRemoteMethod("updateAll", true);             // Removes (POST) /products/update
  Devices.disableRemoteMethod("updateAttributes", false);     // Removes (PUT) /products/:id
  Devices.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

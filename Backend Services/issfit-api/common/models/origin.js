module.exports = function(Origin) {
  Origin.disableRemoteMethod("findOne", true);

  Origin.disableRemoteMethod("confirm", true);
  Origin.disableRemoteMethod("count", true);
  Origin.disableRemoteMethod("exists", true);

  Origin.disableRemoteMethod('create', true);                // Removes (POST) /products
  Origin.disableRemoteMethod('upsert', true);                // Removes (PUT) /products
  Origin.disableRemoteMethod('deleteById', true);            // Removes (DELETE) /products/:id
  Origin.disableRemoteMethod("updateAll", true);             // Removes (POST) /products/update
  Origin.disableRemoteMethod("updateAttributes", false);     // Removes (PUT) /products/:id
  Origin.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

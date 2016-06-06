module.exports = function(Category) {
  Category.disableRemoteMethod("findOne", true);

  Category.disableRemoteMethod("confirm", true);
  Category.disableRemoteMethod("count", true);
  Category.disableRemoteMethod("exists", true);

  Category.disableRemoteMethod('create', true);                // Removes (POST) /products
  Category.disableRemoteMethod('upsert', true);                // Removes (PUT) /products
  Category.disableRemoteMethod('deleteById', true);            // Removes (DELETE) /products/:id
  Category.disableRemoteMethod("updateAll", true);             // Removes (POST) /products/update
  Category.disableRemoteMethod("updateAttributes", false);     // Removes (PUT) /products/:id
  Category.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

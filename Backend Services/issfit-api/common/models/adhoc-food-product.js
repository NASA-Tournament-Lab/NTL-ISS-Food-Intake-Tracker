module.exports = function(AdhocFoodProduct) {
  AdhocFoodProduct.disableRemoteMethod("confirm", true);
  AdhocFoodProduct.disableRemoteMethod("exists", true);

  AdhocFoodProduct.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

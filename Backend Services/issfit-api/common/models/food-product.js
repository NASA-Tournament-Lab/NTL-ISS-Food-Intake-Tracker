module.exports = function(FoodProduct) {
  FoodProduct.disableRemoteMethod("confirm", true);
  FoodProduct.disableRemoteMethod("exists", true);

  FoodProduct.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

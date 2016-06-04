module.exports = function(FoodProductRecord) {
  FoodProductRecord.disableRemoteMethod("confirm", true);
  FoodProductRecord.disableRemoteMethod("exists", true);

  FoodProductRecord.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream
};

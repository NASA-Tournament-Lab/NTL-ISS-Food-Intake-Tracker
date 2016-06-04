module.exports = function(UserLock) {
  UserLock.disableRemoteMethod("confirm", true);
  UserLock.disableRemoteMethod("exists", true);

  UserLock.disableRemoteMethod('upsert', true);                // Removes (PUT) /products
  UserLock.disableRemoteMethod('deleteById', true);            // Removes (DELETE) /products/:id
  UserLock.disableRemoteMethod("updateAll", true);             // Removes (POST) /products/update
  UserLock.disableRemoteMethod("updateAttributes", false);     // Removes (PUT) /products/:id
  UserLock.disableRemoteMethod('createChangeStream', true);    // removes (GET|POST) /products/change-stream

  // enable destroy all with filter
  UserLock.remoteMethod('destroyAll', {
    isStatic: true,
    description: 'Delete all matching records',
    accessType: 'WRITE',
    accepts: {arg: 'where', type: 'object', description: 'filter.where object'},
    http: {verb: 'del', path: '/'}
  });
};

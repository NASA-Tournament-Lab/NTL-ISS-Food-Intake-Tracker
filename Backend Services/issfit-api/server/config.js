var config = {};

config.useApache = true;

config.db = {};
config.db.database = 'pl_fit';
config.db.username =  'pl_fit_db';
config.db.password = 'CHANGEME';
config.db.host =  '192.168.60.53';
config.db.port = 56283;

config.web = {};
config.web.port = config.useApache ? 9090 : 4343;
config.web.key = './ssl/key.pem';
config.web.cert = './ssl/cert.pem';

module.exports = config;

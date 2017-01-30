/**
 * Server file.
 */
var multer        = require('multer');
var loopback      = require('loopback');
var boot          = require('loopback-boot');
var bodyParser    = require('body-parser');
var cookieParser  = require('cookie-parser');
var session       = require('express-session');
var flash         = require('express-flash');
var path          = require('path');
var uuid          = require('node-uuid');

var async         = require('async');
var PythonShell   = require('python-shell');
var lwip          = require('lwip');
var fs            = require('fs');
var config        = require('./config.js');

var https         = require('https');
var sslConfig     = require('./ssl-config');

var unzip         = require('unzip');

var child_process = require('child_process');

var pg            = require('pg');
var knex          = require('knex');

var maxAge = 24 * 3600 * 1000; // 1 day
var MAX_SIZE = 1024;

var foodKeys = ["name", "barcode", "energy", "sodium", "fluid", "protein", "carb", "fat", "categoriesName", "origin",
                "foodImage"];

var foodTitles = ["Name", "Barcode", "Calories", "Sodium", "Fluid", "Protein", "Carb", "Fat", "Categories", "Country Origin",
                  "Food Image"];

var userKeys = ["firstName", "lastName", "dailyTargetEnergy", "dailyTargetSodium", "dailyTargetFluid",
                "dailyTargetProtein", "dailyTargetCarb", "dailyTargetFat", "weight", "admin", "profileImage"];

var userTitles = ["First Name", "Last Name", "Daily Target - Calories", "Daily Target - Sodium", "Daily Target - Fluid",
                  "Daily Target - Protein", "Daily Target - Carb", "Daily Target - Fat", "Weight",
                  "Admin", "Profile Image"];

var defaultValues = { "dailyTargetEnergy": "3500", "dailyTargetSodium": "3500", "dailyTargetFluid": "2500",
                      "dailyTargetProtein": "100", "dailyTargetCarb": "500", "dailyTargetFat": "60" };

var currentNewValues = null;

var allOrigins = undefined;
var allCategories = undefined;

var app = module.exports = loopback();

app.set('views', __dirname + '/../client/views');
app.set('view engine', 'jade'); //Can use any express view engine(Jade/handlebars/haml/react)

app.use(multer({ dest: '/tmp' }).any());
app.use(cookieParser('secret'));
app.use(session({
  resave: false, // don't save session if unmodified
  saveUninitialized: false, // don't create session until something stored
  secret: 'f541b79594f6e0d176058bd4e17874e397e89145',
  cookie: { maxAge: maxAge }
}));
app.use(flash());

// Bootstrap the application, configure models, datasources and middleware.
// Sub-apps like REST API are mounted via boot scripts.
boot(app, __dirname);

var Category = app.loopback.getModel('Category');
var Origin = app.loopback.getModel('Origin');
var NasaUser = app.loopback.getModel('NasaUser');
var FoodProduct = app.loopback.getModel('FoodProduct');
var FoodProductRecord = app.loopback.getModel('FoodProductRecord');
var AdhocFoodProduct = app.loopback.getModel('AdhocFoodProduct');
var FoodProductFilter = app.loopback.getModel('FoodProductFilter');
var Media = app.loopback.getModel('Media');
var UserLock = app.loopback.getModel('UserLock');

var connstr = 'postgres://' + config.db.username + ':' + config.db.password + '@' + config.db.host + ':' + config.db.port + '/' + config.db.database + '?ssl=true';

pg.defaults.ssl = true;
var knex = require('knex')({
  client: 'pg',
  connection: connstr
});

// override String
String.prototype.startsWith = function(prefix) {
    return this.indexOf(prefix) === 0;
}

String.prototype.endsWith = function(suffix) {
    return this.match(suffix+"$") == suffix;
};

/**
 * Return an Object sorted by it's Key
 */
var sortObjectByKey = function(obj, sortKeys){
    var keys = [];
    var sorted_obj = {};

    for(var key in obj){
        if(obj.hasOwnProperty(key)){
            keys.push(key);
        }
    }

    // sort keys
    keys.sort(function(a, b) {
        return sortKeys.indexOf(a)-sortKeys.indexOf(b);
    });

    // create new array based on Sorted Keys
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        sorted_obj[key] = obj[key];
    }

    return sorted_obj;
};

/**
 * Get first key in object.
 */
var firstKey = function(obj) {
    for (var a in obj) return a;
}

// Speed up calls to hasOwnProperty
var hasOwnProperty = Object.prototype.hasOwnProperty;

var isEmpty = function(obj) {

    // null and undefined are "empty"
    if (obj == null) return true;

    // Assume if it has a length property with a non-zero value
    // that that property is correct.
    if (obj.length > 0)    return false;
    if (obj.length === 0)  return true;

    // Otherwise, does it have any properties of its own?
    // Note that this doesn't handle
    // toString and valueOf enumeration bugs in IE < 9
    for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) return false;
    }

    return true;
}

var saveImageFromZip = function(zipFile, done) {
    if (zipFile && zipFile.length > 0) {
        var zip = zipFile[0].path;
        var tmpzipDir = '/tmp/image-' + new Date().getTime();
        fs.mkdirSync(tmpzipDir);
        fs.createReadStream(zip).pipe(unzip.Extract({ path: tmpzipDir })).on('close', function() {
            var queryFunctions = [];
            var imageFiles = fs.readdirSync(tmpzipDir);
            imageFiles.forEach(function(file) {
                if (!file.toUpperCase().endsWith('JPG')) {
                    return;
                }
                queryFunctions.push(function(callback) {
                    saveImageToDB({originalname: file, path: tmpzipDir + '/' + file}, function(err, media) {
                        if (!isEmpty(err)) {
                            callback(err);
                            return;
                        }

                        knex('nasa_user')
                           .innerJoin('user_tmp_table', 'nasa_user.full_name', 'user_tmp_table.full_name')
                           .where('user_tmp_table.profile_image', file)
                           .pluck('uuid').then(function(uuids) {
                                var innerQueryFunctions = [];
                                uuids.forEach(function(uuid) {
                                   innerQueryFunctions.push(function(innerCallback) {
                                       NasaUser.findById(uuid, function(err, result) {
                                           if (!isEmpty(err)) {
                                                innerCallback(err);
                                                return;
                                            }
                                            if (!isEmpty(result)) {
                                                var newValue = JSON.parse(JSON.stringify(result));
                                                newValue['profileImage'] = media.id;
                                                NasaUser.upsert(newValue);
                                                innerCallback(err);
                                            }
                                       });
                                   });
                                });

                                async.waterfall(
                                    innerQueryFunctions,
                                    function (err, result) {
                                        callback(err);
                                    });

                            });
                    });
                });
            });

            async.waterfall(
                queryFunctions,
                function (err, result) {
                    if (err) {
                       console.log('Error saving profile image: ' + JSON.stringify(err));
                    }
                    knex.table('user_tmp_table').truncate().return('finished');
                    done();
                });
        });
    } else {
        knex.table('user_tmp_table').truncate().return('finished');
        done();
    }
}

/**
 * Save image to database.
 */
var saveImageToDB = function(image, callback) {
    try {
        // obtain an image object:
        var originalName = image.originalname;
        console.log("Open lwip: " + image.path);
        fs.readFile(image.path, function(err, imageBuffer) {
            lwip.open(imageBuffer, 'jpg', function(err, currentImage) {
                var batch = currentImage.batch();
                if (undefined != err) {
                    console.log('Error ' + JSON.stringify(err));
                    callback('Error opening image file');
                } else if (currentImage.width() > MAX_SIZE || currentImage.height() > MAX_SIZE) {
                    var rr = currentImage.width() > currentImage.height();
                    var newWidth = rr ? MAX_SIZE : Math.floor(currentImage.width() * (MAX_SIZE / currentImage.height()));
                    var newHeight = rr ? Math.floor(currentImage.height() * (MAX_SIZE / currentImage.width())) : MAX_SIZE;
                    // console.log('Old size: ' + currentImage.width() + ' x ' + currentImage.height());
                    // console.log('New size: ' + newWidth + ' x ' + newHeight);
                    batch.resize(newWidth, newHeight);
                }
                batch.toBuffer("jpg", function(errToBuffer, buffer) {
                    if (!isEmpty(errToBuffer)) {
                        callback('Error saving image file to database');
                        return;
                    }
                    var now = new Date();
                    var newMedia = {
                      "filename": originalName,
                      "data": buffer,
                      "createdDate": now,
                      "modifiedDate": now,
                      "removed": false,
                      "synchronized": true
                    };
                    Media.create(newMedia, callback);
                });
            });
        });
    } catch (err) {
        console.log('Error: ' + err);
        callback('Error saving image file to database');
    }
}

var updateValue = function(req, res) {
    var newValue = {};

    var isFood = req.url.indexOf('food') != -1;
    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    var object = isFood ? FoodProduct : NasaUser;
    var origin, originName;
    var foodChanged = false, barcodeChanged = false, fullnameChanged = false;
    queryFunctions.push(function(callback) {
        object.findById(req.params.id, function(err, result) {
            if (!isEmpty(err)) {
                    callback(err);
            } else {
                newValue = JSON.parse(JSON.stringify(result));
                var tmpBody = JSON.parse(JSON.stringify(req.body));

                origin = newValue["origin"];
                allOrigins.forEach(function(o) {
                    if (o.id == origin) originName = o.value;
                });

                for (var key in tmpBody) {
                    if (tmpBody.hasOwnProperty(key)) {
                        var value = tmpBody[key];
                        if (isFinite(String(value).trim() || NaN) && key != "barcode") {
                            newValue[key] = new Number(value);
                        } else if (isEmpty(value)) {
                            delete newValue[key];
                        } else {
                            if (key == 'barcode') barcodeChanged = newValue[key] != value;
                            if (key == 'name') foodChanged = newValue[key] != value.trim();
                            newValue[key] = value !== undefined ? value.trim() : value;
                        }
                    }
                }

                newValue["removed"] = false;
                if (isFood) {
                  newValue["active"] = true;

                  allOrigins.forEach(function(o) {
                      if (o.value == newValue["origin"]) newValue["origin"] = o.id;
                  });
                  foodChanged = foodChanged || (origin !== newValue["origin"]);
                } else {
                  var fullName = newValue["firstName"].trim().toString() + " " + newValue["lastName"].trim().toString();
                  fullnameChanged = newValue["fullName"].toLowerCase() != fullName.toLowerCase();
                  newValue["fullName"] = fullName;
                  newValue["admin"] = newValue["admin"] == 1;

                  delete newValue["firstName"];
                  delete newValue["lastName"];
                }
                newValue["synchronized"] = true;
                newValue["modifiedDate"] = new Date();

                console.log("New value: " + JSON.stringify(newValue));

                callback(null);
            }
        });
    })


    if (!isFood) {
        // check userlock exists
        queryFunctions.push(function(callback) {
            UserLock.find({ where : {user_uuid : req.params.id} }, function(err, results) {
                if (!isEmpty(err)) {
                    callback(err);
                } else {
                    if (!isEmpty(results)) {
                        var rows = JSON.parse(JSON.stringify(results));
                        callback("User is being used by device: " + rows[0]["device_uuid"]);
                    } else {
                        callback(null);
                    }
                }
            });
        });
    }

    var files = req["files"] !== undefined ? JSON.parse(JSON.stringify(req["files"])) : undefined;
    if (!isEmpty(files)) {
        var key = files[0]["fieldname"];
        var image = files[0];
        if (undefined != image) {
            var originalName = image.originalname;

            queryFunctions.push(function(callback) {
                saveImageToDB(image, function(err, media) {
                      if (err) {
                          callback(err);
                      } else {
                          newValue[key] = media.id;
                          callback(null);
                      }
                });
            });
        }
    }

    var message = isFood ? "Food Data Updated" : "User Profile Updated";
    if (isFood) { // execute for FoodProduct only
        queryFunctions.push(function(callback) {
            FoodProduct.find(function(err, results) {
                if (err) {
                    callback(err);
                } else {
                    var foods = JSON.parse(JSON.stringify(results));
                    for (var i = 0; i < foods.length; i++) {
                        var value = foods[i];
                        if (!isEmpty(value.name) && value.name.toString().trim().toLowerCase() === newValue["name"].trim().toLowerCase() &&
                            !isEmpty(value.origin) && value.origin.trim().toLowerCase() == newValue["origin"].trim().toLowerCase() && foodChanged) {
                            callback('Food with name "' + value.name + '" and origin "' + originName + '" already exists');
                            return;
                        }
                        if (!isEmpty(value.barcode) && !isEmpty(newValue["barcode"]) && value.barcode.toString().trim() === newValue["barcode"].toString().trim() && barcodeChanged) {
                            callback('Food with barcode "' + value.barcode + '" already exists');
                            return;
                        }
                    }
                    callback(null);
                }
            });
        });

        // update category / origin
        queryFunctions.push(function(callback) {
            var tmpCategory = newValue["categoriesName"];
            if (undefined != tmpCategory && tmpCategory.length > 0) {
                var categories = tmpCategory instanceof Array ? tmpCategory : new Array(tmpCategory);
                var catIds = [];
                for (var i = 0; i < categories.length; i++) {
                    allCategories.forEach(function(o) {
                        if (o.value == categories[i])
                            catIds.push(o.id);
                        else if (o.id == categories[i])
                            catIds.push(o.id);
                    });
                }
                newValue["category_uuids"] = catIds;
            } else if (undefined !== newValue["categoriesId"]) {
                newValue["category_uuids"] = newValue["categoriesId"].split(',');
            }

            // clean up
            delete newValue["categories"];
            delete newValue["categoriesId"];
            delete newValue["categoriesName"];

            callback(null);
        });
    } else {
      // check user exists
      queryFunctions.push(function(callback) {
          NasaUser.find(function(err, results) {
              if (err) {
                  callback(err);
              } else {
                  var users = JSON.parse(JSON.stringify(results));
                  for (var i = 0; i < users.length; i++) {
                      var value = users[i];
                      if (!isEmpty(value.fullName) && value.fullName.toString().trim().toLowerCase() === newValue["fullName"].trim().toLowerCase() && fullnameChanged) {
                          callback('User with name "' + value.fullName + '" already exists!');
                          return;
                      }
                  }
                  callback(null);
              }
          });
      });
    }

    queryFunctions.push(function(callback) {
        console.log("Upsert:" + JSON.stringify(newValue));
        object.upsert(newValue, function(err) {
              if (isEmpty(err)) {
                  callback(null);
              } else {
                  callback(err);
              }
        });
    })

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                console.log("Error while updating value:\n\t" + JSON.stringify(err));
                req.flash('error', err);
                res.redirect((isFood ? '/food/' : '/user/') + req.params.id);
            } else {
                req.flash('currentSelectedTab', isFood ? '1' : '0');
                req.flash('message', message);
                res.redirect('/');
            }
    });
}

var checkCategoryOrigin = function(queryFunctions) {
    if (allCategories === undefined) {
        queryFunctions.push(function(callback) {
            Category.find(function(err, results) {
                if (err) {
                    callback(err);
                } else {
                    allCategories = JSON.parse(JSON.stringify(results));
                    callback(null);
                }
            });
        });
    }

    if (allOrigins === undefined) {
        queryFunctions.push(function(callback) {
            Origin.find(function(err, results) {
                if (err) {
                    callback(err);
                } else {
                    allOrigins = JSON.parse(JSON.stringify(results));
                    callback(null);
                }
            });
        });
    }
}

// Root page
app.get('/', function (req, res) {
    var query = req.query && req.query['currentSelectedTab'] ? req.query['currentSelectedTab'].toString() : undefined;
    var currentSelectedTab =  query || req.flash('currentSelectedTab');
    var message = req.flash('message');
    var error = req.flash('error');

    var currentSession = req.session;

    currentNewValues = null;

    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                res.redirect('/');
            } else {
                res.render('index', {
                    tabsData: JSON.stringify({
                        selectedTab: currentSelectedTab.length > 0 ? new Number(currentSelectedTab) : 0,
                        message: message || "",
                        error: error || "",
                        showLogout: false
                    })
                });
            }
    });
});

// Get user and foods list
app.get('/users', function (req, res) {
    NasaUser.find({ where : {removed: false} }, function(err, results) {
        if(err) {
            return console.error('error running query', err);
        }

        var rows = [];
        var users = JSON.parse(JSON.stringify(results));
        for (var i = 0; i < users.length; i++) {
            var value = users[i];
            if (value.removed == 0) {
                var obj = {
                    "id": value.id,
                    "name": value.fullName
                };
                rows.push(obj);
            }
        }

        res.render('tabs',
            {
                message: 'User Data',
                action: '/user',
                rows: rows,
                tableId: 'userTable'
            },
            function(err, html) {
                res.send(html);
        });
    });
});

app.get('/foods', function (req, res) {
    if (allCategories === undefined || allOrigins === undefined) {
        req.flash('currentSelectedTab', '1');
        res.redirect('/');
        return;
    }

    FoodProduct.find({ where : { removed: false } }, function(err, results) {
        if (err) {
            return console.error('error running query', err);
        }

        var rows = [];
        var foods = JSON.parse(JSON.stringify(results));
        for (var i = 0; i < foods.length; i++) {
            var value = foods[i];

            var origin = "";
            allOrigins.forEach(function(o) {
                if (o.id == value["origin"])
                    origin = o.value;
            });

            if (value.removed == 0) {
                var obj = {
                    "id": value.id,
                    "name": value.name,
                    "origin": origin
                };
                rows.push(obj);
            }
        }

        res.render('tabs',
            {
                message: 'Food Data',
                action: '/food',
                rows: rows,
                tableId: 'foodTable'
            },
            function(err, html) {
                res.send(html);
        });
    });
});


// report
app.get('/reports', function(req, res) {
    NasaUser.find(function(err, results) {
        if(err) {
            return console.error('error running query', err);
        }
        var rows = [];
        var users = JSON.parse(JSON.stringify(results));
        for (var i = 0; i < users.length; i++) {
            var value = users[i];
            if (value.removed == 0) {
                var obj = {
                    "id": value.id,
                    "name": value.fullName
                };
                rows.push(obj);
            }
        }

        res.render('reports', {
            users: rows,
            message: 'Select Reports'
        }, function(err, html) {
            res.send(html);
        });
    });
});

// import data
app.get('/import', function(req, res) {
    res.render('import', {
            message: 'Import CSV file',
            functions: ['Load Food', 'Load User']
        }, function(err, html) {
            res.send(html);
        });
});

// Get user and foods list
app.get('/delete', function (req, res) {
    req.session.downloadComplete = 0;
    NasaUser.find({ where : { removed: true } }, function(err, results) {
        if (err) {
            return console.error('error running query', err);
        }

        var rows = [];
        var users = JSON.parse(JSON.stringify(results));
        for (var i = 0; i < users.length; i++) {
            var value = users[i];
            if (value.removed == 1) {
                var obj = {
                    "id": value.id,
                    "name": value.fullName
                };
                rows.push(obj);
            }
        }

        res.render('tabs',
            {
                message: 'Deleted User Data',
                action: '/delete',
                rows: rows,
                tableId: 'deletedTable'
            },
            function(err, html) {
                res.send(html);
        });
    });
});

// instructions - help
app.get('/instructions', function(req, res) {
    res.render('instructions', {
            message: 'Instructions'
        }, function(err, html) {
            res.send(html);
        });
});

// Show foods / users new
app.get('/user', function(req, res) {
    res.render('new', { message: "New user", action: "/user", keys: userKeys, titles: userTitles, defaultValues: currentNewValues || defaultValues,
                        uuid: uuid.v4(), error: req.flash('error') || '' });
    req.flash('currentSelectedTab', '0');
});

app.get('/food', function(req, res) {
    res.render('new', { message: "New food", action: "/food", keys: foodKeys, titles: foodTitles, defaultValues: currentNewValues || defaultValues,
                        uuid: uuid.v4(), error: req.flash('error') || '' });
    req.flash('currentSelectedTab', '1');
});

// Create new food / user
app.post('/food', function(req, res) {
    var newValue = {};
    var tempBody = JSON.parse(JSON.stringify(req.body));
    var id = tempBody["id"];
    for (var key in tempBody) {
        if (tempBody.hasOwnProperty(key) && key != "id") {
            var value = tempBody[key];
            if (isFinite(String(value).trim() || NaN) && key != "barcode") {
                newValue[key] = new Number(value);
            } else {
                newValue[key] = value;
            }
        }
    }
    newValue["name"] = newValue["name"].toString();
    newValue["origin"] = newValue["origin"].toString();
    newValue["active"] = true;
    newValue["removed"] = false;
    newValue["synchronized"] = true;

    newValue["quantity"] = 0.0;

    var now = new Date();
    newValue["createdDate"] = now;
    newValue["modifiedDate"] = now;

    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    queryFunctions.push(function(callback) {
        // update origin
        var origin, originName;
        allOrigins.forEach(function(o) {
          if (o.value == newValue["origin"]) origin = o.id;
        });
        originName = newValue["origin"];
        newValue["origin"] = origin;

        FoodProduct.find(function(err, results) {
            if (err) {
                callback(err);
            } else {
                var foods = JSON.parse(JSON.stringify(results));

                for (var i = 0; i < foods.length; i++) {
                    var value = foods[i];
                    if (!isEmpty(value.name) && value.name.toString().trim().toLowerCase() === newValue["name"].trim().toLowerCase() &&
                        !isEmpty(value.origin) && value.origin.trim().toLowerCase() == newValue["origin"].trim().toLowerCase()) {
                        callback('Food with name "' + value.name + '" and origin "' + originName + '" already exists');
                        return;
                    }
                    if (!isEmpty(value.barcode) && !isEmpty(newValue["barcode"]) && value.barcode.toString().trim() === newValue["barcode"].toString().trim()) {
                        callback('Food with barcode "' + value.barcode + '" already exists');
                        return;
                    }
                }
                callback(null);
            }
        });
    });

    // fetch categories
    queryFunctions.push(function(callback) {
        var newCategories = newValue["categoriesName"] instanceof Array ? newValue["categoriesName"] : new Array(newValue["categoriesName"]);
        var catIds = [];
        for (var i = 0; i < newCategories.length; i++) {
            allCategories.forEach(function(o) {
                if (o.value == newCategories[i])
                    catIds.push(o.id);
            });
        }
        newValue["category_uuids"] = catIds;

        callback(null);
    });

    var files = req["files"] !== undefined ? JSON.parse(JSON.stringify(req["files"])) : undefined;
    if (!isEmpty(files)) {
        var foodImage = files[0];
        var originalName = foodImage.originalname;

        /*queryFunctions.push(function(callback) {
            Media.destroyAll({filename: originalName}, function(err) {
                callback(err);
            });
        });*/

        // obtain an image object:
        queryFunctions.push(function(callback) {
            saveImageToDB(foodImage, function(err, media) {
                  if (err) {
                      callback(err);
                  } else {
                      newValue["foodImage"] = media.id;
                      callback(null);
                  }
            });
        });
    }

    queryFunctions.push(function(callback) {
        FoodProduct.create(newValue, function(err, result) {
            if (err) {
                console.log("Error");
                callback(JSON.stringify(err));
            } else {
                console.log("Created");
                callback(null);
            }
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                console.log("error  " + err);
                req.flash('error', err);
                currentNewValues = newValue;
                res.redirect('/food');
            } else {
                req.flash('message', 'New Food Data Created');
                req.flash('currentSelectedTab', '1');
                res.redirect('/');
            }
    });
});

app.post('/user', function(req, res) {
    var id = req.body["id"];
    var newValue = {};
    var tempBody = JSON.parse(JSON.stringify(req.body));
    for (var key in tempBody) {
        if (tempBody.hasOwnProperty(key) && key != "id") {
            var value = tempBody[key];
            if (isFinite(String(value).trim() || NaN) && key != "barcode") {
                newValue[key] = new Number(value);
            } else {
                newValue[key] = value;
            }
        }
    }
    newValue["fullName"] = newValue["firstName"].toString() + " " + newValue["lastName"].toString();
    delete newValue["firstName"];
    delete newValue["lastName"];

    newValue["removed"] = false;
    newValue["synchronized"] = true;
    newValue["admin"] = newValue["admin"] == 1;

    var now = new Date();
    newValue["createdDate"] = now;
    newValue["modifiedDate"] = now;

    var queryFunctions = [];

    // check user exists
    queryFunctions.push(function(callback) {
        NasaUser.find(function(err, results) {
            if (err) {
                callback(err);
            } else {
                var users = JSON.parse(JSON.stringify(results));
                for (var i = 0; i < users.length; i++) {
                    var value = users[i];
                    if (!isEmpty(value.fullName) && value.fullName.toString().trim().toLowerCase() === newValue["fullName"].trim().toLowerCase()) {
                        callback('User with name "' + value.fullName + '" already exists!');
                        return;
                    }
                }
                callback(null);
            }
        });
    });

    // check image file
    var files = req["files"] !== undefined ? JSON.parse(JSON.stringify(req["files"])) : undefined;
    if (!isEmpty(files)) {
        var profileImageFile = files[0];
        var originalName = profileImageFile.originalname;

        /*queryFunctions.push(function(callback) {
              Media.destroyAll({filename : originalName}, function(err) {
                  callback(err);
              });
        });*/

        // obtain an image object:
        queryFunctions.push(function(callback) {
              saveImageToDB(profileImageFile, function(err, media) {
                  if (err) {
                      callback(err);
                  } else {
                      newValue["profileImage"] = media.id;
                      callback(null);
                  }
              });
        });
    }

    queryFunctions.push(function(callback) {
        NasaUser.create(newValue, function(err, result) {
            if (err) {
                console.log("Error");
                callback(JSON.stringify(err));
            } else {
                console.log("Created");
                callback(null);
            }
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                req.flash('error', err);
                currentNewValues = newValue;
                res.redirect('/user');
            } else {
                req.flash('message', 'New User Profile Created');
                req.flash('currentSelectedTab', '0');
                res.redirect('/');
            }
    });
});

var editObject = null;
var editImage = null;

// Load food / user
app.get('/food/:id', function(req, res) {
    console.log("Param: " + req.params.id);

    var error = req.flash('error');
    if (undefined != error && error.length > 0) {
        res.render('edit', {
            message: editObject.name,
            action: '/food/' + req.params.id,
            obj: sortObjectByKey(editObject, foodKeys),
            editKeys: foodKeys,
            titles: foodTitles,
            image_jpg: editImage || '',
            error: error || ''
        });
        return;
    }

    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    queryFunctions.push(function(callback) {
       FoodProduct.findById(req.params.id, function(err, result) {
            if (!isEmpty(err)) {
                callback('error running query');
                return;
            }

            editObject = JSON.parse(JSON.stringify(result));
            editObject.categoriesId = editObject["category_uuids"] || [];
            editObject.categoriesName = [];

            for (var i = 0; i < editObject.categoriesId.length; i++) {
                allCategories.forEach(function(o) {
                    if (o.id == editObject.categoriesId[i])
                        editObject.categoriesName.push(o.value);
                });
            }

            allOrigins.forEach(function(o) {
                if (o.id == editObject["origin"]) editObject["origin"] = o.value;
            });

            console.log("Result: " + JSON.stringify(editObject));

            callback(null);
        });
    })

    queryFunctions.push(function(callback) {
        Media.findById(editObject["foodImage"], function(err, result) {
            if (!isEmpty(err)) {
                callback('error running query');
                return;
            }
            if (!isEmpty(result)) {
                var media = JSON.parse(JSON.stringify(result));
                if (!isEmpty(media.data)) {
                    if (media.data["type"] == "Buffer") {
                        var buffer = new Buffer(media.data["data"]);
                        editImage = buffer.toString('base64');
                    } else {
                        var buffer = new Buffer(media["data"]);
                        editImage = buffer.toString('base64');
                    }
                }
            }
            callback(null);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                console.log("error  " + err);
                req.flash('error', err);
                res.redirect('/');
            } else {
                res.render('edit', {
                        message: editObject.name,
                        action: '/food/' + req.params.id,
                        obj: sortObjectByKey(editObject, foodKeys),
                        editKeys: foodKeys,
                        titles: foodTitles,
                        image_jpg: editImage || '',
                        error: ''
                });
            }
    });
});

app.get('/user/:id', function(req, res) {
    console.log("Param: " + req.params.id);

    var error = req.flash('error');
    if (undefined != error && error.length > 0) {
        res.render('edit', {
            message: editObject.fullName,
            action: '/user/' + req.params.id,
            obj: sortObjectByKey(editObject, foodKeys),
            editKeys: userKeys,
            titles: userTitles,
            image_jpg: editImage || '',
            error: error || ''
        });
        return;
    }

    var queryFunctions = [];
    var locked = false;

    queryFunctions.push(function(callback) {
        NasaUser.findById(req.params.id, function(err, result) {
            if (!isEmpty(err)) {
                callback('error running query');
                return;
            }

            editObject = JSON.parse(JSON.stringify(result));
            editObject["firstName"] = editObject["fullName"].split(" ")[0];
            editObject["lastName"] = editObject["fullName"].split(" ")[1];
            locked = !isEmpty(editObject.userLock);

            console.log("Result: " + JSON.stringify(editObject));

            callback(null);
        });
    });

    queryFunctions.push(function(callback) {
        Media.findById(editObject["profileImage"], function(err, result) {
            if (!isEmpty(err)) {
                callback('error running query');
                return;
            }
            if (!isEmpty(result)) {
                var media = JSON.parse(JSON.stringify(result));
                if (!isEmpty(media.data)) {
                    if (media.data["type"] == "Buffer") {
                        var buffer = new Buffer(media.data["data"]);
                        editImage = buffer.toString('base64');
                    } else {
                        var buffer = new Buffer(media["data"]);
                        editImage = buffer.toString('base64');
                    }
                }
            }
            callback(null);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                console.log("error  " + err);
                req.flash('error', err);
                res.redirect('/');
            } else {
                res.render('edit', {
                        message: editObject.fullName,
                        action: '/user/' + req.params.id,
                        obj: sortObjectByKey(editObject, userKeys),
                        editLock: locked,
                        editKeys: userKeys,
                        titles: userTitles,
                        image_jpg: editImage || '',
                        error: ''
                });
            }
    });
});

// Update food / user

app.post('/food/:id', function(req, res) {
    updateValue(req, res);
});

app.post('/user/:id', function(req, res) {
    updateValue(req, res);
});

app.post('/reports', function(req, res) {
    console.log('Body: ' + JSON.stringify(req.body));

    var args = ['--database=' + config.db.database,
                '--user=' + config.db.username,
                '--password=' + config.db.password,
                '--host=' + config.db.host,
                '--port=' + config.db.port];
    var tmpBody = JSON.parse(JSON.stringify(req.body));
    if (tmpBody.radioReport == "0") {
        if (undefined != tmpBody.users && tmpBody.users.length > 0) {
            var users = tmpBody.users instanceof Array ? tmpBody.users : new Array(tmpBody.users);
            args.push('--selected=' + users.join(","));
        } else {
            req.flash('currentSelectedTab', '2');
            req.flash('error', "Please select a user");
            res.redirect('/');
            return;
        }
    }
    if (tmpBody.details == "on") {
        args.push('-f');
    }
    if (tmpBody.startDate && tmpBody.startDate.trim().length > 0) {
       var dates = tmpBody.startDate.split('/');
       args.push('-s' + parseInt(dates[2]) + parseInt(dates[0]) + parseInt(dates[1]));
    }
    if (tmpBody.endDate && tmpBody.endDate.trim().length > 0) {
       var dates = tmpBody.endDate.split('/');
       args.push('-e' + parseInt(dates[2]) + parseInt(dates[0]) + parseInt(dates[1]));
    }

    PythonShell.run('generateSummary.py', {
        args: args,
        mode: 'text',
        pythonPath: '/usr/bin/python',
        scriptPath: __dirname + '/..'
    }, function (err, results) {
        if (err) {
            console.log("Error: " + err.traceback);
            res.status(err.status).end();
            return;
        }
        console.log('finished');
        console.log(results);

        res.download(__dirname + '/../reports/summary.zip', 'summary.zip', function (err) {
            if (err) {
                console.log('generateSummary.py error: ' + JSON.stringify(err));
                res.status(err.status).end();
            } else {
                console.log('Sent');
            }
        });
    });
});

app.post('/import', function(req, res) {
    req.flash('currentSelectedTab', '3');

    var body = JSON.parse(JSON.stringify(req.body));
    var isScript = body.script === 'on';
    var files = req["files"] !== undefined ? JSON.parse(JSON.stringify(req["files"])) : undefined;
    if (!isEmpty(files)) {
        var functions = [];
        var zipFile = files.filter(function(file) {
            return file.fieldname == 'userImageFileImport';
        });

        files = files.filter(function(file) {
            return file.fieldname != 'userImageFileImport';
        });

        for (var i = 0; i < files.length; i++) {
            var currentFile = files[i];
            console.log('Current file: ' + JSON.stringify(currentFile));
            if (currentFile.fieldname == 'userFileImport' && currentFile.mimetype == 'text/csv') {
                var argsUser = [
                    config.db.host,
                    config.db.username,
                    config.db.database,
                    config.db.port,
                    config.db.password,
                    currentFile['path']
                ];

                console.log('Preparing user: ' + JSON.stringify(argsUser));
                functions.push(function(callback) {
                    console.log('Executing user: ' + JSON.stringify(argsUser));
                    child_process.execFile(__dirname + '/../loadUser.sh', argsUser, function(err, stderr, stdout) {
                        if (err) {
                            callback(err + '\n' + stderr);
                        } else {
                            console.log(stdout);
                            callback(null);
                        }
                    });
                });

            } else if (currentFile.fieldname == 'foodFileImport' && currentFile.mimetype == 'text/csv') {
                var argsFood = [
                    config.db.host,
                    config.db.username,
                    config.db.database,
                    config.db.port,
                    config.db.password,
                    currentFile['path']
                ];
                if (body.clear == "on") {
                    argsFood.push("1");
                } else {
                    argsFood.push("0");
                }

                console.log('Preparing food: ' + JSON.stringify(argsFood));
                functions.push(function(callback) {
                    console.log('Executing food: ' + JSON.stringify(argsFood));
                    child_process.execFile(__dirname + '/../loadFood.sh', argsFood, function(err, stderr, stdout) {
                        if (err) {
                            callback(err + '\n' + stderr);
                        } else {
                            console.log(stdout);
                            callback(null);
                        }
                    });
                });
            }
        }

        async.waterfall(
            functions,
            function (err, result) {
                if (isScript) {
                    if (err) {
                        console.log('Error: ' + err);
                        res.status(500).send({success: false, error: err});
                    } else {
                        saveImageFromZip(zipFile, function() {
                            res.json({success: true})
                        });
                    }
                } else {
                    if (err) {
                        console.log('Error: ' + err);
                        req.flash('error', err);
                        res.redirect('/');
                    } else {
                        saveImageFromZip(zipFile, function() {
                            req.flash('message', 'Bulk Upload Successful');
                            res.redirect('/');
                        });
                    }
                }
        });
    } else {
        req.flash('error', 'Please select a file');
        res.redirect('/');
    }
});

// Delete user food records
app.get('/delete/execute/:id', function(req, res) {
    NasaUser.findById(req.params.id, function(err, user) {
        if (!user) {
            req.flash('error', 'User not found for id: ' + req.params.id);
            req.flash('currentSelectedTab', '4');
            return res.redirect('/');
        }

        var queryFunctions = [];
        var profileImageId = user.profileImage;

        queryFunctions.push(function(callback) {
            UserLock.destroyAll({ user_uuid: user.id }, function(err, result) {
                console.log('Deleted UserLock with result: ' + JSON.stringify(result));
                callback(err);
            });
        });
        queryFunctions.push(function(callback) {
            var innerQueryFunctions = [];
            user.toJSON().consumptionRecord.forEach(function(record) {
                innerQueryFunctions.push(function(cb) {
                    if (record.voiceRecordings && record.voiceRecordings.length > 0) {
                      FoodProductRecord.findById(record.id, function(err, r) {
                        if (err) {
                          cb(err); return;
                        }
                        r.voiceRecordings.destroyAll(function(err, result) {
                            console.log('Deleted voiceRecordings with result: ' + JSON.stringify(result));
                            cb(err);
                        });
                      });
                    } else {
                      cb(null);
                    }
                });
            });
            innerQueryFunctions.push(function(cb) {
                user.consumptionRecord.destroyAll(function(err, result) {
                    console.log('Deleted FoodProductRecord with result: ' + JSON.stringify(result));
                    cb(err);
                })
            });

            async.waterfall(
                innerQueryFunctions,
                function (err) {
                    callback(err);
            });
        });
        queryFunctions.push(function(callback) {
            FoodProductFilter.destroyAll( { user_uuid : user.id }, function(err, result) {
                console.log('Deleted FoodProductFilter with result: ' + JSON.stringify(result));
                callback(err);
            });
        });
        queryFunctions.push(function(callback) {
            user.adhocFoodProduct.destroyAll(function(err, result) {
                console.log('Deleted AdhocFoodProduct with result: ' + JSON.stringify(result));
                callback(err);
            });
        });
        queryFunctions.push(function(callback) {
            user.destroy(function(err, result) {
                console.log('Deleted user with result: ' + JSON.stringify(result));
                callback(err);
            });
        });
        if (profileImageId) {
          queryFunctions.push(function(callback) {
              Media.destroyById(profileImageId, function(err, mediaResult) {
                  console.log('Deleted media with result: ' + JSON.stringify(mediaResult));
                  callback(err);
              });
          });
        }

        async.waterfall(
            queryFunctions,
            function (err, result) {
                if (err) {
                    console.log('Error: ' + err);
                    req.flash('error', 'User data was not removed');
                    req.flash('currentSelectedTab', '4');
                    res.redirect('/');
                } else {
                    req.flash('message', 'User data was removed from database');
                    req.flash('currentSelectedTab', '4');
                    res.redirect('/');
                }
        });
    });
})

app.get('/delete/refresh/:id', function(req, res) {
    if (req.session.downloadComplete == null || req.session.downloadComplete < 2) {
        return res.json({
          success: false,
          downloadComplete: req.session.downloadComplete
        });
    }

    res.json({
      success: true
    })
});

app.get('/delete/:id', function(req, res) {
    var args = ['--database=' + config.db.database,
                '--user=' + config.db.username,
                '--password=' + config.db.password,
                '--host=' + config.db.host,
                '--port=' + config.db.port,
                '--selected=' + req.params.id,
                '-f'];

    req.session.downloadComplete = 1;
    PythonShell.run('generateSummary.py', {
        args: args,
        mode: 'text',
        pythonPath: '/usr/bin/python',
        scriptPath: __dirname + '/..'
    }, function (err, results) {
        if (err) {
            console.log("Error: " + err.traceback);
            res.status(err.status).end();
            return;
        }

        console.log('Before download');
        res.download(__dirname + '/../reports/summary.zip', 'summary.zip', function (err) {
            if (err) {
                console.log('generateSummary.py error: ' + JSON.stringify(err));
                req.session.downloadComplete = -1;
                req.session.save(function(err) {
                  res.status(err.status).end();
                });
            } else {
                req.session.downloadComplete = 2;
                req.session.save(function(err) {
                  res.end();
                });
            }
        });
    });
});

// Delete food/user and user lock
app.get('/delete/user/:id', function(req, res) {
    var queryFunctions = [];

    // check userlock exists
    queryFunctions.push(function(callback) {
        UserLock.find({ where : {user_uuid : req.params.id} }, function(err, results) {
            if (!isEmpty(err)) {
                callback(err);
            } else {
                if (!isEmpty(results)) {
                    var rows = JSON.parse(JSON.stringify(results));
                    callback("User is being used by device: " + rows[0]["device_uuid"]);
                } else {
                    callback(null);
                }
            }
        });
    });

    queryFunctions.push(function(callback) {
        NasaUser.findById(req.params.id, function(err, object) {
            if (!isEmpty(err)) {
                callback(err);
            } else {
                callback(null, object);
            }
        });
    });

    queryFunctions.push(function(object, callback) {
        object.removed = true;
        object.modifiedDate = new Date();
        object.save(function(err) {
            callback(err);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err) {
            if (err != null) {
                console.log("Error while updating value:\n\t" + JSON.stringify(err));
                req.flash('error', JSON.stringify(err));
                res.redirect('/user/' + req.params.id);
            } else {
                req.flash('currentSelectedTab', '0');
                req.flash('message', "User Deleted");
                res.redirect('/');
            }
    });
});

app.get('/delete/food/:id', function(req, res) {
    var queryFunctions = [];

    queryFunctions.push(function(callback) {
        FoodProduct.findById(req.params.id, function(err, object) {
            if (!isEmpty(err)) {
                callback(err);
            } else {
                callback(null, object);
            }
        });
    });

    queryFunctions.push(function(object, callback) {
        object.removed = true;
        object.modifiedDate = new Date();
        object.save(function(err) {
            callback(err);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err) {
            if (err != null) {
                console.log("Error while updating value:\n\t" + JSON.stringify(err));
                req.flash('error', JSON.stringify(err));
                res.redirect('/food/' + req.params.id);
            } else {
                req.flash('currentSelectedTab', '1');
                req.flash('message', "Food Deleted");
                res.redirect('/');
            }
    });
});

app.get('/force/user/:id', function(req, res) {
    var id = req.params.id;
    UserLock.destroyAll({ user_uuid: id }, function(err) {
        if (err) {
            return console.error('error running query', err);
        }
        res.redirect('/user/' + id);
    });
});

var httpsOptions = {
  key: sslConfig.privateKey,
  cert: sslConfig.certificate
};

app.start = function() {
  // start the web server
  var port = app.get('port');

  https.createServer(httpsOptions, app).listen(port, function() {
    app.emit('started');
    console.log('Web server listening at: %s', app.get('url'));
  });
};

// start the server if `$ node server.js`
if (require.main === module) {
  app.start();
}

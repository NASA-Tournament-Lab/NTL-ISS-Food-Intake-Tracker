var multer      = require('multer');
var loopback    = require('loopback');
var boot        = require('loopback-boot');
var bodyParser  = require('body-parser');
var cookieParser = require('cookie-parser');
var session     = require('express-session');
var flash       = require('express-flash');
var path        = require('path');
var uuid        = require('node-uuid');

var async       = require('async');
var PythonShell = require('python-shell');
var lwip        = require('lwip');

var maxAge = 60 * 60 * 1000;

var foodKeys = ["name", "barcode", "energy", "sodium", "fluid", "protein", "carb", "fat", "categoriesName", "origin",
                "productProfileImage"];
var foodTitles = ["Name", "Barcode", "Energy", "Sodium", "Fluid", "Protein", "Carb", "Fat", "Categories", "Country Origin",
                  "Food Image"];

var userKeys = ["fullName", "dailyTargetEnergy", "dailyTargetSodium", "dailyTargetFluid",
                "dailyTargetProtein", "dailyTargetCarb", "dailyTargetFat", "weight", "admin", "profileImage"];
var userTitles = ["Name", "Daily Target - Energy", "Daily Target - Sodium", "Daily Target - Fluid",
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

// to support JSON-encoded bodies
app.middleware('parse', bodyParser.json());
// to support URL-encoded bodies
app.middleware('parse', bodyParser.urlencoded({
  extended: true
}));

app.use(multer({ dest: '/tmp' }).single('photo'));

app.use(cookieParser('secret'));
// app.use(session({cookie: { maxAge: 60000 }}));
app.use(session({
  resave: false, // don't save session if unmodified
  saveUninitialized: false, // don't create session until something stored
  secret: 'f541b79594f6e0d176058bd4e17874e397e89145',
  cookie: { maxAge: maxAge }
}));
app.use(flash());

//request limit 1gb
app.use(loopback.bodyParser.json({limit: 524288000}));
app.use(loopback.bodyParser.urlencoded({limit: 524288000, extended: true}));

// Bootstrap the application, configure models, datasources and middleware.
// Sub-apps like REST API are mounted via boot scripts.
boot(app, __dirname);

var Category = app.loopback.getModel('Category');
var Origin = app.loopback.getModel('Origin');
var NasaUser = app.loopback.getModel('NasaUser');
var FoodProduct = app.loopback.getModel('FoodProduct');
var Media = app.loopback.getModel('Media');
var UserLock = app.loopback.getModel('UserLock');

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

var updateValue = function(req, res, remove) {
    var newValue = {};

    var isFood = req.url.indexOf('food') != -1;
    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    var object = isFood ? FoodProduct : NasaUser;
    queryFunctions.push(function(callback) {
        object.findById(req.params.id, function(err, result) {
            if (!isEmpty(err)) {
                    callback(err);
            } else {
                newValue = JSON.parse(JSON.stringify(result));
                var tmpBody = JSON.parse(JSON.stringify(req.body));
                for (var key in tmpBody) {
                    if (tmpBody.hasOwnProperty(key)) {
                        var value = tmpBody[key];
                        if (isFinite(String(value).trim() || NaN) && key != "barcode") {
                            newValue[key] = new Number(value);
                        } else if (isEmpty(value)) {
                            delete newValue[key];
                        } else {
                            newValue[key] = value;
                        }
                    }
                }

                newValue["removed"] = remove ? 1 : 0;
                newValue["active"] = 1;
                newValue["synchronized"] = 1;
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
                console.log("err :  " + JSON.stringify(err));
                console.log("result :  " + JSON.stringify(results));
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

    var message = "";
    if (remove) {
        message = isFood ? "Food Deleted" : "User Profile Deleted";
    } else {
        message = isFood ? "Food Data Updated" : "User Profile Updated";
    }

    if (isFood) { // execute for FoodProduct only
        queryFunctions.push(function(callback) {
            FoodProduct.find(function(err, results) {
                if (err) {
                    callback(err);
                } else {
                    var foods = JSON.parse(JSON.stringify(results));
                    for (var i = 0; i < foods.length; i++) {
                        var value = foods[i];
                        if (!isEmpty(value.barcode) && !isEmpty(newValue["barcode"]) && value.barcode.toString().trim() === newValue["barcode"].toString().trim()) {
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

            var origin;
            allOrigins.forEach(function(o) {
                if (o.value == newValue["origin"])
                    origin = o.id;
            });
            newValue["origin"] = origin;

            // clean up
            delete newValue["categories"];
            delete newValue["categoriesId"];
            delete newValue["categoriesName"];

            callback(null);
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

app.get('/', function (req, res) {
    var currentSelectedTab = req.flash('currentSelectedTab');
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


app.get('/users', function (req, res) {
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
    FoodProduct.find(function(err, results) {
        if(err) {
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
    NasaUser.find(function(err, users) {
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

app.get('/import', function(req, res) {
    res.render('import', {
            message: 'Import CSV file',
            functions: ['Load Food', 'Load User']
        }, function(err, html) {
            res.send(html);
        });
});

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
    newValue["name"] = newValue["name"].toString();
    newValue["origin"] = newValue["origin"].toString();
    newValue["active"] = 1;
    newValue["removed"] = 0;
    newValue["synchronized"] = 1;

    newValue["quantity"] = 0.0;

    var now = new Date();
    newValue["createdDate"] = now;
    newValue["modifiedDate"] = now;

    console.log("==>  " + JSON.stringify(newValue));

    var queryFunctions = [];

    checkCategoryOrigin(queryFunctions);

    queryFunctions.push(function(callback) {
        FoodProduct.find(function(err, results) {
            if (err) {
                callback(err);
            } else {
                var foods = JSON.parse(JSON.stringify(results));
                for (var i = 0; i < foods.length; i++) {
                    var value = foods[i];
                    if (!isEmpty(value.name) && value.name.toString().trim().toLowerCase() === newValue["name"].trim().toLowerCase() &&
                        !isEmpty(value.origin) != null && value.origin.trim() == newValue["origin"].trim()) {
                        callback('Food with name "' + value.name + '" and origin "' + value.origin + '" already exists');
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

        var origin;
        allOrigins.forEach(function(o) {
            if (o.value == newValue["origin"])
                origin = o.id;
        });
        newValue["origin"] = origin;

        callback(null);
    });

    if (undefined != req.files && undefined != req.files["productProfileImage"]) {
        var productProfileImage = req.files["productProfileImage"];
        var originalName = productProfileImage.originalname;

        queryFunctions.push(function(callback) {
              callback(null);
        });

        // obtain an image object:
        queryFunctions.push(function(callback) {
             // saveImageToDB(productProfileImage, callback);
              newValue["foodImage"] = originalName;
              callback(null);
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
    newValue["fullName"] = newValue["fullName"].toString();
    newValue["active"] = 1;
    newValue["removed"] = 0;
    newValue["synchronized"] = 1;

    var now = new Date();
    newValue["createdDate"] = now;
    newValue["modifiedDate"] = now;

    var queryFunctions = [];

    // check user exists
    queryFunctions.push(function(callback) {
        FoodProduct.find(function(err, results) {
            if (err) {
                callback(err);
            } else {
                var foods = JSON.parse(JSON.stringify(results));
                for (var i = 0; i < foods.length; i++) {
                    var value = foods[i];
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
    if (undefined != req.files && undefined != req.files["profileImage"]) {
        var profileImageFile = req.files["profileImage"];
        var originalName = profileImageFile.originalname;
        newValue["profileImage"] = originalName;

        queryFunctions.push(function(callback) {
              callback(null);
        });

        // obtain an image object:
        queryFunctions.push(function(callback) {
              // saveImageToDB(profileImageFile, callback);
              callback(null);
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
                if (o.id == editObject["origin"])
                    editObject["origin"] = o.value;
            });

            console.log("Result: " + JSON.stringify(editObject));

            callback(null);
        });
    })

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
            locked = !isEmpty(editObject.userLock);

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
app.post('/user/:id', function(req, res) {
    updateValue(req, res, false);
});

app.post('/food/:id', function(req, res) {
    updateValue(req, res, false);
});

app.post('/reports', function(req, res) {
    console.log('Body: ' + JSON.stringify(req.body));

    var args = [];
    if (req.body.radioReport == "0") {
        if (undefined != req.body.users && req.body.users.length > 0) {
            var users = req.body.users instanceof Array ? req.body.users : new Array(req.body.users);
            args.push('--selected=' + users.join(","));
        } else {
            req.flash('currentSelectedTab', '2');
            req.flash('error', "Please select a user");
            res.redirect('/');
            return;
        }
    }

    PythonShell.run('generateSummary.py', {
        args: args,
        mode: 'text',
        pythonPath: '/usr/bin/python',
        scriptPath: __dirname
    }, function (err, results) {
        if (err) {
            console.log("Error: " + err.traceback);
            return;
        }
        console.log('finished');
        console.log(results);

        res.download(__dirname + '/reports/summary.zip', 'summary.zip', function (err) {
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

    console.log('Files: ' + JSON.stringify(req.files));
    if (undefined != req.files && !isEmpty(req.files)) {
        var functions = [];
        if (undefined != req.files['userFileImport']) {
            functions.push(function(callback) {
                var userFileImport = req.files['userFileImport'];
                var path = userFileImport['path'];
                var args = [];
                PythonShell.run('loadUser.py', {
                    args: args,
                    mode: 'text',
                    pythonPath: '/usr/bin/python',
                    scriptPath: __dirname
                }, function (err, results) {
                    if (err != null) {
                        console.log("Food error: " + JSON.stringify(err));
                        callback('Error loading user.\nPlease check the CSV file format.');
                    } else {
                        callback(null);
                    }
                });
            });

        }
        if (undefined != req.files['foodFileImport']) {
            functions.push(function(callback) {
                var foodFileImport = req.files['foodFileImport'];
                var path = foodFileImport['path'];
                var args = [];
                PythonShell.run('loadFood.py', {
                    args: args,
                    mode: 'text',
                    pythonPath: '/usr/bin/python',
                    scriptPath: __dirname
                }, function (err, results) {
                    if (err != null) {
                        console.log("Food error: " + err.traceback);
                        callback('Error loading food.\nPlease check the CSV file format.');
                    } else {
                        callback(null);
                    }
                });
            });
        }

        async.waterfall(
            functions,
            function (err, result) {
                if (err) {
                    req.flash('error', err);
                } else {
                    req.flash('message', 'Bulk Upload Successful');
                }
                res.redirect('/');
        });
    } else {
        req.flash('error', 'Please select a file');
        res.redirect('/');
    }
});

// Delete food/user and user lock
app.get('/delete/user/:id', function(req, res) {
    updateValue(req, res, true);
});

app.get('/delete/food/:id', function(req, res) {
    updateValue(req, res, true);
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

app.start = function() {
  // start the web server
  return app.listen(function() {
    app.emit('started');
    var baseUrl = app.get('url').replace(/\/$/, '');
    console.log('Web server listening at: %s', baseUrl);
    if (app.get('loopback-component-explorer')) {
      var explorerPath = app.get('loopback-component-explorer').mountPath;
      console.log('Browse your REST API at %s%s', baseUrl, explorerPath);
    }
  });
};

// start the server if `$ node server.js`
if (require.main === module) {
  app.start();
}

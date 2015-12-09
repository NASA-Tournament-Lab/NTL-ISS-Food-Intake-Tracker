var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var flash = require('connect-flash');
var async = require('async');
var pg = require('pg');
var format = require('pg-format');
var uuid = require('node-uuid');
var bodyParser = require('body-parser');
var multer = require('multer');
var fs = require('fs');
var PythonShell = require('python-shell');
var lwip = require('lwip');
var config = require('./config');
var format = require('pg-format');
var https = require('https');

var app = express();

// set pretty html
app.locals.pretty = true;

var maxAge = 60 * 60 * 1000;

app.use( bodyParser.json() );  // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({
  extended: true
})); // to support URL-encoded bodies
app.use(multer({ dest: '/tmp' }));
app.use(express.static(__dirname + '/public'));

app.use(cookieParser('secret'));
// app.use(session({cookie: { maxAge: 60000 }}));
app.use(session({
  resave: false, // don't save session if unmodified
  saveUninitialized: false, // don't create session until something stored
  secret: 'f541b79594f6e0d176058bd4e17874e397e89145',
  cookie: { maxAge: maxAge }
}));
app.use(flash());

app.set('views', './views');
app.set('view engine', 'jade');

var server, pgclient, MAX_SIZE = 1024;

var conString = "postgres://" + config.db.username + ":" + config.db.password+ "@" + config.db.host+ ":" +
                config.db.port + "/" + config.db.database + "?ssl=true";

var foodKeys = ["name", "barcode", "energy", "sodium", "fluid", "protein", "carb", "fat", "categories", "origin",
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

var key = fs.readFileSync(config.web.key);
var cert = fs.readFileSync(config.web.cert);
var https_options = {
    key: key,
    cert: cert
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

/**
 * Save image to database.
 */
var saveImageToDB = function(image, callback) {
    try {
        // obtain an image object:
        var originalName = image.originalname;
        lwip.open("/tmp/" + image.name, function(err, currentImage) {
            var batch = currentImage.batch();
            if (undefined != err) {
                console.log('Error ' + JSON.stringify(err));
                callback('Error opening image file');
            } else if (currentImage.width() > MAX_SIZE || currentImage.height() > MAX_SIZE) {
                var rr = currentImage.width() > currentImage.height();
                var newWidth = rr ? MAX_SIZE : Math.floor(currentImage.width() * (MAX_SIZE / currentImage.height()));
                var newHeight = rr ? Math.floor(currentImage.height() * (MAX_SIZE / currentImage.width())) : MAX_SIZE;
                console.log('Old size: ' + currentImage.width() + ' x ' + currentImage.height());
                console.log('New size: ' + newWidth + ' x ' + newHeight);
                batch.resize(newWidth, newHeight);
            }
            batch.toBuffer("jpg", function(errToBuffer, buffer) {
                if (errToBuffer) {
                    console.log('Error: ' + JSON.stringify(errToBuffer));
                    callback('Error saving image file to database');
                    return;
                }
                var mediaQuery = format("INSERT INTO media VALUES(%L, %L, 'file_load');",
                                        originalName, buffer);
                console.log("Query (Media): " + mediaQuery);
                pgclient.query(mediaQuery, function(err, results) {
                    if (err != null) {
                        console.log('Error: ' + JSON.stringify(err));
                        callback('Error saving image file to database');
                    } else {
                        callback(null);
                    }
                });;
            });
        });
    } catch (err) {
        console.log('Error: ' + JSON.stringify(err));
        callback('Error saving image file to database');
    }
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

/**
 * Update value column in data table.
 */
var updateValue = function(req, res, remove) {
    var newValue = {};
    for (var key in req.body) {
        if (req.body.hasOwnProperty(key)) {
            var value = req.body[key];
            if (isFinite(String(value).trim() || NaN) && key != "barcode") {
                newValue[key] = new Number(value);
            } else {
                newValue[key] = value;
            }
        }
    }
    if (remove) {
        newValue["removed"] = 1;
    }

    var queryFunctions = [];

    if (undefined != req.files) {
        var key = firstKey(req.files);
        var image = req.files[key];
        if (undefined != image) {
            var originalName = image.originalname;
            newValue[key] = originalName;
            var deleteQuery = format("DELETE FROM media WHERE filename = %L", originalName);
            queryFunctions.push(function(callback) {
                console.log("Query (Media): " + deleteQuery);
                pgclient.query(deleteQuery, function(err, results) {
                    callback(err);
                });
            });

            queryFunctions.push(function(callback) {
                saveImageToDB(image, callback);
            });
        }
    }

    // add category
    var tmpCategory = newValue["categories"];
    if (undefined != tmpCategory && tmpCategory.length > 0) {
        var categories = tmpCategory instanceof Array ? tmpCategory : new Array(tmpCategory);
        var catIds = [];
        var queryIds = [];
        var queryCatData = [];
        for (var i = 0; i < categories.length; i++) {
            if (/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(categories[i])) {
                catIds.push(categories[i]);
                console.log("Pushing existing " + categories[i]);
                continue;
            }

            var id = uuid.v4();

            catIds.push(id);
            queryIds.push(id);
            queryCatData.push({
                synchronized: 1,
                value: categories[i],
                removed: 0
            });

            queryFunctions.push(function(callback) {
                var catId = queryIds.pop();
                var data = queryCatData.pop();
                var catQuery = format("INSERT INTO data VALUES(%L, 'StringWrapper', %L, 'now', 'now', 'file_load');", catId, JSON.stringify(data));
                pgclient.query(catQuery, function(err, results) {
                    console.log("Query (StringWrapper): " + catQuery);
                    callback(err);
                });
            });
        }
        newValue["categories"] = catIds.join(";");
    } else if (undefined != newValue["categoriesId"]) {
        newValue["categories"] = newValue["categoriesId"].replace(",", ";");
    }
    delete newValue["categoriesId"];

    queryFunctions.push(function(callback) {
        pgclient.query("BEGIN", function(err, results) {
            console.log("BEGIN UPDATE");
            callback(err);
        });
    });
    var query = format("UPDATE data SET value = %L, modifieddate = 'now', modifiedby = 'file_load' WHERE id = %L",
                       JSON.stringify(newValue), req.params.id);
    queryFunctions.push(function(callback) {
        console.log("Update query: " + query);
        pgclient.query(query, function(err, results) {
            callback(err);
        });
    });

    queryFunctions.push(function(callback) {
        pgclient.query("COMMIT", function(err, results) {
            console.log("COMMIT UPDATE");
            callback(err);
        });
    });

    var isFood = req.url.indexOf('food') != -1;
    var message = "";
    if (remove) {
        message = isFood ? "Food Deleted" : "User Profile Deleted";
    } else {
        message = isFood ? "Food Data Updated" : "User Profile Updated";
    }
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

function requiredAuthentication(req, res, next) {
        if (config.useApache) {
                next();
                return;
        }

    var currentSession = req.session;
    if (currentSession.loggedIn != null && currentSession.loggedIn) {
        next();
    } else {
        req.session.error = 'Access denied!';
        res.redirect('/login');
    }
}

app.get('/login', function (req, res) {
    var currentSelectedTab = req.flash('currentSelectedTab');
    var message = req.flash('message');
    var error = req.flash('error');

    res.render('login', {
        tabsData: JSON.stringify({
            message: message || "",
            error: error || ""
        })
    });
});

app.get('/logout', function (req, res) {
    req.session.destroy(function() {
        res.redirect('/');
    });
});

app.get('/', function (req, res) {
    var currentSelectedTab = req.flash('currentSelectedTab');
    var message = req.flash('message');
    var error = req.flash('error');

    var currentSession = req.session;

    currentNewValues = null;

    if (!config.useApache && (currentSession == null || currentSession.loggedIn == null || !currentSession.loggedIn)) {
        res.redirect('/login');
    } else {
        res.render('index', {
            tabsData: JSON.stringify({
                selectedTab: currentSelectedTab.length > 0 ? new Number(currentSelectedTab) : 0,
                message: message || "",
                error: error || "",
                showLogout: !config.useApache
            })
        });
    }
});

// List foods / users

app.get('/foods', requiredAuthentication, function (req, res) {
    pgclient.query("SELECT id, name, value FROM data WHERE name = 'FoodProduct'", function(err, result) {
        if(err) {
            return console.error('error running query', err);
        }
        var rows = [];
        for (var i = 0; i < result.rows.length; i++) {
            var row = result.rows[i];
            var value = JSON.parse(row.value);
            if (value.removed == 0) {
                var obj = {
                    "id": row.id,
                    "name": value.name,
                    "origin": value.origin
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

app.get('/users', requiredAuthentication, function (req, res) {
    pgclient.query("SELECT id, name, value FROM data WHERE name = 'User'", function(err, result) {
        if(err) {
            return console.error('error running query', err);
        }
        var rows = [];
        for (var i = 0; i < result.rows.length; i++) {
            var row = result.rows[i];
            var value = JSON.parse(row.value);
            if (value.removed == 0) {
                var obj = {
                    "id": row.id,
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

// report
app.get('/reports', requiredAuthentication, function(req, res) {
    pgclient.query("SELECT id, name, value FROM data WHERE name = 'User'", function(err, result) {
        if(err) {
            return console.error('error running query', err);
        }
        var rows = [];
        for (var i = 0; i < result.rows.length; i++) {
            var row = result.rows[i];
            var value = JSON.parse(row.value);
            if (value.removed == 0) {
                var obj = {
                    "id": row.id,
                    "name": value.fullName
                };
                rows.push(obj);
            }
        }
        console.log('REPORTS ' + JSON.stringify(rows));

        res.render('reports', {
            users: rows,
            message: 'Select Reports'
        }, function(err, html) {
            res.send(html);
        });
    });
});

app.get('/import', requiredAuthentication, function(req, res) {
    res.render('import', {
            message: 'Import CSV file',
            functions: ['Load Food', 'Load User']
        }, function(err, html) {
            res.send(html);
        });
});

app.get('/instructions', requiredAuthentication, function(req, res) {
    res.render('instructions', {
            message: 'Instructions'
        }, function(err, html) {
            res.send(html);
        });
});

// Show foods / users new
app.get('/user', requiredAuthentication, function(req, res) {
    res.render('new', { message: "New user", action: "/user", keys: userKeys, titles: userTitles, defaultValues: currentNewValues || defaultValues,
                        uuid: uuid.v4(), error: req.flash('error') || '' });
    req.flash('currentSelectedTab', '0');
});

app.get('/food', requiredAuthentication, function(req, res) {
    res.render('new', { message: "New food", action: "/food", keys: foodKeys, titles: foodTitles, defaultValues: currentNewValues || defaultValues,
                        uuid: uuid.v4(), error: req.flash('error') || '' });
    req.flash('currentSelectedTab', '1');
});

// Login
app.post('/login', function(req, res) {
    var currentSession = req.session;

    var username = req.body.username;
    var password = req.body.password;
    if (undefined == username || username.trim().length == 0) {
        req.flash('error', 'Username cannot be empty');
        res.redirect('/');
        return;
    }
    if (undefined == password || password.trim().length == 0) {
        req.flash('error', 'Password cannot be empty');
        res.redirect('/');
    }

    pgclient.query("SELECT login('" + username + "', '" + password + "') is NULL as check", function(err, result) {
        if(err || result.rows.length == 0) {
            return console.error('error running query', err);
        }

        console.log("Result: " + result.rows[0].check);
        if (result.rows[0].check) {
            req.flash('error', 'Wrong username or password');
            res.redirect('/');
        } else {
            currentSession.loggedIn = true;
            res.redirect('/');
        }
    });
});

// Create new food / user
app.post('/food', requiredAuthentication, function(req, res) {
    var id = req.body["id"];
    var newValue = {};
    for (var key in req.body) {
        if (req.body.hasOwnProperty(key) && key != "id") {
            var value = req.body[key];
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

    console.log("==>  " + JSON.stringify(newValue));

    var queryFunctions = [];

    // check food exists
    queryFunctions.push(function(callback) {
        pgclient.query("SELECT value FROM data WHERE name = 'FoodProduct'", function(err, results) {
            if (err) {
                callback(err);
            } else {
                for (var i = 0; i < results.rows.length; i++) {
                    var row = results.rows[i];
                    var value = JSON.parse(row.value);
                    if (value.name != null && value.name.toString().trim().toLowerCase() === newValue["name"].trim().toLowerCase() &&
                        value.origin != null && value.origin.trim() == newValue["origin"].trim()) {
                        callback('Food with name "' + value.name + '" and origin "' + value.origin + '" already exists');
                        return;
                    }
                    if (value.barcode != null && newValue["barcode"] != null && value.barcode.toString().trim() === newValue["barcode"].toString().trim()) {
                        callback('Food with barcode "' + value.barcode + '" already exists');
                        return;
                    }
                }
                callback(null);
            }
        });
    });

    // add category
    var categories = newValue["categories"] instanceof Array ? newValue["categories"] : new Array(newValue["categories"]);
    var catIds = [];
    var tmpCategories = [];
    var tmpCatIds = [];
    for (var i = 0; i < categories.length; i++) {
        var tmpCatId = uuid.v4();

        catIds.push(tmpCatId);
        tmpCatIds.push(tmpCatId);
        tmpCategories.push({
            synchronized: 1,
            value: categories[i],
            removed: 0
        });

        queryFunctions.push(function(callback) {
            var catId = tmpCatIds.pop();
            var data = tmpCategories.pop();
            var catQuery = format("INSERT INTO data VALUES(%L, 'StringWrapper', %L, 'now', 'now', 'file_load');", catId, JSON.stringify(data));
            console.log("Query (StringWrapper): " + catQuery);
            pgclient.query(catQuery, function(err, results) {
                callback(err != null ? 'Error inserting category "' + data.value + '" into database' : null);
            });
        });
    }

    if (undefined != req.files && undefined != req.files["productProfileImage"]) {
        var productProfileImage = req.files["productProfileImage"];
        var originalName = productProfileImage.originalname;
        newValue["productProfileImage"] = originalName;

        var deleteQuery = format("DELETE FROM media WHERE filename = %L", originalName);
        queryFunctions.push(function(callback) {
            console.log("Query (Media): " + deleteQuery);
            pgclient.query(deleteQuery, function(err, results) {
                callback(err != null ? 'Error inserting media "' + originalName + '" into database' : null);
            });
        });

        // obtain an image object:
        queryFunctions.push(function(callback) {
            saveImageToDB(productProfileImage, callback);
        });
    }

    queryFunctions.push(function(callback) {
        newValue["categories"] = catIds.join(";");

        var query = format("INSERT INTO data VALUES(%L, 'FoodProduct', %L, 'now', 'now', 'file_load');", id, JSON.stringify(newValue));
        console.log("Query (FoodProduct): " + query);
        pgclient.query(query, function(err, results) {
            callback(err != null ? 'Error inserting food "' + newValue.name + '" into database' : null, results);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err != null) {
                req.flash('error', err);
                currentNewValues = newValue;
                res.redirect('/food');
            } else {
                req.flash('message', 'New Food Data Created');
                res.redirect('/');
            }
    });
});

app.post('/user', requiredAuthentication, function(req, res) {
    var id = req.body["id"];
    var newValue = {};
    for (var key in req.body) {
        if (req.body.hasOwnProperty(key) && key != "id") {
            var value = req.body[key];
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

    var queryFunctions = [];

    // check user exists
    queryFunctions.push(function(callback) {
        pgclient.query("SELECT value FROM data WHERE name = 'User'", function(err, results) {
            if (err) {
                callback(err);
            } else {
                for (var i = 0; i < results.rows.length; i++) {
                    var row = results.rows[i];
                    var value = JSON.parse(row.value);
                    if (value.fullName != null && value.fullName.toString().trim().toLowerCase() === newValue["fullName"].trim().toLowerCase()) {
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

        var deleteQuery = format("DELETE FROM media WHERE filename = %L", originalName);
        queryFunctions.push(function(callback) {
            console.log("Query (Media): " + deleteQuery);
            pgclient.query(deleteQuery, function(err, results) {
                callback(err != null ? 'Error inserting media "' + originalName + '" into database' : null);
            });
        });

        // obtain an image object:
        queryFunctions.push(function(callback) {
            saveImageToDB(profileImageFile, callback);
        });
    }

    var toSave = JSON.stringify(newValue);
    var query = format("INSERT INTO data VALUES(%L, 'User', %L, 'now', 'now', 'file_load');", id, toSave);
    queryFunctions.push(function(callback) {
        console.log("Query (User): " + query);
        pgclient.query(query, function(err, results) {
            callback(err != null ? 'Error inserting user "' + newValue.fullName + '" into database' : null, results);
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
})

var editObject = null;
var editImage = null;

// Load food / user
app.get('/food/:id', requiredAuthentication, function(req, res) {
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

    async.waterfall([
        function(callback) {
            pgclient.query("SELECT id, value FROM data WHERE name = 'StringWrapper';", function(err, result) {
                if(err || result.rows.length == 0) {
                    return console.error('error running query', err);
                }
                var rows = {};
                for (var i = 0; i < result.rows.length; i++) {
                    var row = result.rows[i];
                    var category = JSON.parse(row.value);
                    rows[row.id] = category.value;
                }

                callback(null, rows);
            });
        },
        function(categoryRows, callback) {
            pgclient.query("SELECT id, value FROM data WHERE id = '" + req.params.id + "';", function(err, result) {
                if(err || result.rows.length == 0) {
                    return console.error('error running query', err);
                }
                var row = result.rows[0];

                editObject = JSON.parse(row.value);
                editObject["categories"] = editObject["categories"] || "";

                var categoriesId = editObject["categories"].split(";");
                var categories = [];
                for (var i = 0; i < categoriesId.length; i++) {
                    categories.push(categoryRows[categoriesId[i]]);
                }
                console.log('Categories ' + JSON.stringify(categories));

                editObject["categories"] = categories;
                editObject["categoriesId"] = categoriesId;

                console.log("Result: " + JSON.stringify(editObject));

                pgclient.query("SELECT encode(data, 'base64') AS value FROM media WHERE filename = '" + editObject["productProfileImage"] + "';", function(err, result) {
                    editImage = result.rows.length > 0 && result.rows[0] != null ? result.rows[0].value : '';

                    res.render('edit', {
                            message: editObject.name,
                            action: '/food/' + req.params.id,
                            obj: sortObjectByKey(editObject, foodKeys),
                            editKeys: foodKeys,
                            titles: foodTitles,
                            image_jpg: editImage,
                            error: ''
                    });
                });
            });
        }
    ],
        function (err, result) {
            console.log('End');
    });
});

app.get('/user/:id', requiredAuthentication, function(req, res) {
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

    pgclient.query("SELECT value FROM data WHERE id = '" + req.params.id + "';", function(err, result) {
        if (err || result.rows.length == 0) {
            return console.error('error running query', err);
        }

        console.log("Result: " + result.rows[0].value);
        editObject = JSON.parse(result.rows[0].value);

        pgclient.query("SELECT encode(data, 'base64') AS value FROM media WHERE filename = '" + editObject["profileImage"] + "';", function(err, result) {
            editImage = result.rows.length > 0 && result.rows[0] != null ? result.rows[0].value : '';

            res.render('edit', {
                message: editObject.fullName,
                action: '/user/' + req.params.id,
                obj: sortObjectByKey(editObject, userKeys),
                editKeys: userKeys,
                titles: userTitles,
                image_jpg: editImage,
                error: ''
            });
        });
    });
});

// Update food / user

app.post('/user/:id', requiredAuthentication, function(req, res) {
    updateValue(req, res, false);
});

app.post('/food/:id', requiredAuthentication, function(req, res) {
    updateValue(req, res, false);
});

app.post('/reports', requiredAuthentication, function(req, res) {
    console.log('Body: ' + JSON.stringify(req.body));

    var args = ['--database=' + config.db.database,
                '--user=' + config.db.username,
                '--password=' + config.db.password,
                '--host=' + config.db.host,
                '--port=' + config.db.port];
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

app.post('/import', requiredAuthentication, function(req, res) {
    req.flash('currentSelectedTab', '3');

    console.log('Files: ' + JSON.stringify(req.files));
    if (undefined != req.files && !isEmpty(req.files)) {
        var functions = [];
        if (undefined != req.files['userFileImport']) {
            functions.push(function(callback) {
                var userFileImport = req.files['userFileImport'];
                var path = userFileImport['path'];
                var args = ['--database=' + config.db.database,
                            '--user=' + config.db.username,
                            '--password=' + config.db.password,
                            '--host=' + config.db.host,
                            '--port=' + config.db.port,
                            '--filename=' + path];
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
                var args = ['--database=' + config.db.database,
                            '--user=' + config.db.username,
                            '--password=' + config.db.password,
                            '--host=' + config.db.host,
                            '--port=' + config.db.port,
                            '--filename=' + path];
                PythonShell.run('loadFood.py', {
                    args: args,
                    mode: 'text',
                    pythonPath: '/usr/bin/python',
                    scriptPath: __dirname
                }, function (err, results) {
                    if (err != null) {
                        console.log("Food error: " + JSON.stringify(err));
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

// Delete food/user

app.get('/delete/user/:id', requiredAuthentication, function(req, res) {
    updateValue(req, res, true);
});

app.get('/delete/food/:id', requiredAuthentication, function(req, res) {
    updateValue(req, res, true);
});

pg.connect(conString, function(err, client, done) {
    if(err) {
        return console.error('error fetching client from pool', err);
    }
    pgclient = client;
        server = https.createServer(https_options, app);
        if (config.useApache) {
               server.listen(config.web.port, 'localhost', function() {
                     console.log('Listening at localhost on port %d', server.address().port);
               });
        } else {
               server.listen(config.web.port, function() {
                 console.log('Listening on port %d', server.address().port);
           });
        }
});

var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var flash = require('connect-flash');
var async = require('async');
var pg = require('pg');
var escape = require('pg-escape');
var uuid = require('node-uuid');
var bodyParser = require('body-parser');
var multer = require('multer');
var fs = require('fs');
var PythonShell = require('python-shell');
var lwip = require('lwip');

var app = express();

app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({
  extended: true
})); // to support URL-encoded bodies
app.use(multer({ dest: '/tmp' }));
app.use(express.static(__dirname + '/public'));

app.use(cookieParser('secret'));
app.use(session({cookie: { maxAge: 60000 }}));
app.use(flash());

app.set('views', './views');
app.set('view engine', 'jade');

var server, pgclient, conString = "postgres://postgres:12345@localhost/nasadb", MAX_SIZE = 1024;

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

    // add category
    var tmpCategory = newValue["categories"];
    if (undefined != tmpCategory && tmpCategory.length > 0) {
        var categories = tmpCategory instanceof Array ? tmpCategory : new Array(tmpCategory);
        var catIds = [];
        for (var i = 0; i < categories.length; i++) {
            if (/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(categories[i])) {
                catIds.push(categories[i]);
                console.log("Pushing existing " + categories[i]);
                continue;
            }

            var catId = uuid.v4();
            var data = {
                synchronized: 1,
                value: categories[i],
                removed: 0
            };
            var catQuery = escape("INSERT INTO data VALUES(%L, 'StringWrapper', %L, 'now', 'now', 'file_load');", catId,
                                       JSON.stringify(data));
            queryFunctions.push(function(callback) {
                pgclient.query(catQuery, function(err, results) {
                    console.log("Query (StringWrapper): " + catQuery);
                    callback(err);
                });
            });
            catIds.push(catId);
        }
        newValue["categories"] = catIds.join(";");
    } else if (undefined != newValue["categoriesId"]) {
        newValue["categories"] = newValue["categoriesId"].replace(",", ";");
    }
    delete newValue["categoriesId"];

    if (undefined != req.files) {
        var key = firstKey(req.files);
        var image = req.files[key];
        if (undefined != image) {
            newValue[key] = image.originalname;
            var deleteQuery = escape("DELETE FROM media WHERE filename = %L", image.originalname);
            queryFunctions.push(function(callback) {
                console.log("Query (Media): " + deleteQuery);
                pgclient.query(deleteQuery, function(err, results) {
                    callback(err);
                });
            });

            queryFunctions.push(function(callback) {
                // obtain an image object:
                lwip.open("/tmp/" + image.name, function(err, currentImage) {
                    if (currentImage.width() > MAX_SIZE || currentImage.height() > MAX_SIZE) {
                        var rr = currentImage.width() > currentImage.height();
                        var newWidth = rr ? MAX_SIZE : Math.floor(currentImage.width() * (MAX_SIZE / currentImage.height()));
                        var newHeight = rr ? Math.floor(currentImage.height() * (MAX_SIZE / currentImage.width())) : MAX_SIZE;
                        console.log('Old size: ' + currentImage.width() + ' x ' + currentImage.height());
                        console.log('New size: ' + newWidth + ' x ' + newHeight);
                        currentImage.batch()
                            .resize(newWidth, newHeight)
                            .writeFile("/tmp/resized.jpg", function(err) {
                                var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                                        image.originalname, "/tmp/resized.jpg");
                                console.log("Query (Media): " + mediaQuery);
                                pgclient.query(mediaQuery, function(err, results) {
                                    callback(err);
                                });
                            });
                    } else {
                        var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                                 image.originalname, "/tmp/" + image.name);
                        console.log("Query (Media): " + mediaQuery);
                        pgclient.query(mediaQuery, function(err, results) {
                            callback(err);
                        });
                    }
                });
            });
        }
    }

    console.log("Param: " + JSON.stringify(newValue));

    queryFunctions.push(function(callback) {
        pgclient.query("BEGIN", function(err, results) {
            callback(err);
        });
    });
    var query = escape("UPDATE data SET value = %L, modifieddate = 'now', modifiedby = 'file_load' WHERE id = %L",
                       JSON.stringify(newValue), req.params.id);
    queryFunctions.push(function(callback) {
        console.log("Update query: " + query);
        pgclient.query(query, function(err, results) {
            callback(err);
        });
    });

    queryFunctions.push(function(callback) {
        pgclient.query("COMMIT", function(err, results) {
            callback(err);
        });
    });

    var isFood = req.url.indexOf('food') != -1;
    var message = "";
    if (remove) {
        message = isFood ?  "Food Deleted" : "User Profile Deleted";
    } else {
        message = isFood ?  "Food Edit Saved" : "User Profile Edit Saved";
    }
    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err) {
                req.flash('error', JSON.stringify(err));
            } else {
                req.flash('message', message);
            }
            res.redirect('/');
    });
}

app.get('/', function (req, res) {
    var currentSelectedTab = req.flash('currentSelectedTab');
    var message = req.flash('message');
    var error = req.flash('error');
    res.render('index', {
        tabsData: JSON.stringify({
            selectedTab: currentSelectedTab.length > 0 ? new Number(currentSelectedTab) : 0,
            message: message || "",
            error: error || ""
        })
    });
});

// List foods / users
app.get('/foods', function (req, res) {
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
                    "name": value.name
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

app.get('/users', function (req, res) {
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
app.get('/reports', function(req, res) {
    pgclient.query("SELECT id, name, value FROM data WHERE name = 'User'", function(err, result) {
        if(err) {
            return console.error('error running query', err);
        }
        var rows = [];
        for (var i = 0; i < result.rows.length; i++) {
            var row = result.rows[i];
            var value = JSON.parse(row.value);
            var obj = {
                "id": row.id,
                "name": value.fullName
            };
            rows.push(obj);
        }
        console.log('REPORTS ' + JSON.stringify(rows));

        res.render('reports', {
            users: rows,
            message: 'Select report'
        }, function(err, html) {
            res.send(html);
        });
    });
});

app.get('/import', function(req, res) {
    req.flash('currentSelectedTab', '3');
    res.render('import', {
            message: 'Import csv file',
            functions: ['Load Food', 'Load User']
        }, function(err, html) {
            res.send(html);
        });
});

app.get('/instructions', function(req, res) {
    req.flash('currentSelectedTab', '4');
    res.render('instructions', {
            message: 'Instructions'
        }, function(err, html) {
            res.send(html);
        });
});

// Show foods / users new
app.get('/food', function(req, res) {
    req.flash('currentSelectedTab', '1');
    res.render('new', { message: "New food", action: "/food", keys: foodKeys, titles: foodTitles, defaultValues: {},
                        uuid: uuid.v4() });
});

app.get('/user', function(req, res) {
    req.flash('currentSelectedTab', '0');
    res.render('new', { message: "New user", action: "/user", keys: userKeys, titles: userTitles, defaultValues: defaultValues,
                        uuid: uuid.v4() });
});

// Create new food / user
app.post('/food', function(req, res) {
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
    newValue["active"] = 1;
    newValue["removed"] = 0;
    newValue["synchronized"] = 1;

    var queryFunctions = [];

    if (undefined == newValue["name"] || newValue["name"].trim().length == 0) {
        req.flash("error", "Name cannot be empty");
        res.redirect('/');
        return;
    }

    // check food exists
    queryFunctions.push(function(callback) {
        pgclient.query("SELECT value FROM data WHERE name = 'FoodProduct'", function(err, results) {
            if (err) callback(err);
            for (var i = 0; i < results.rows.length; i++) {
                var row = results.rows[i];
                var value = JSON.parse(row.value);
                if (value.name.trim() === newValue["name"].trim()) {
                    callback("Food already exists");
                    return;
                }
            }
            callback(null);
        });
    });

    // add category
    var categories = newValue["categories"] instanceof Array ? newValue["categories"] : new Array(newValue["categories"]);
    var catIds = [];
    for (var i = 0; i < categories.length; i++) {
        var catId = uuid.v4();
        var data = {
            synchronized: 1,
            value: categories[i],
            removed: 0
        };
        var catQuery = escape("INSERT INTO data VALUES(%L, 'StringWrapper', %L, 'now', 'now', 'file_load');", catId,
                                   JSON.stringify(data));
        queryFunctions.push(function(callback) {
            console.log("Query (StringWrapper): " + catQuery);
            pgclient.query(catQuery, function(err, results) {
                callback(err);
            });
        });
        catIds.push(catId);
    }
    newValue["categories"] = catIds.join(";");

    if (undefined != req.files && undefined != req.files["productProfileImage"]) {
        var productProfileImage = req.files["productProfileImage"];
        newValue["productProfileImage"] = productProfileImage.originalname;

        var deleteQuery = escape("DELETE FROM media WHERE filename = %L", productProfileImage.originalname);
        queryFunctions.push(function(callback) {
            console.log("Query (Media): " + deleteQuery);
            pgclient.query(deleteQuery, function(err, results) {
                callback(err);
            });
        });

        // obtain an image object:
        lwip.open("/tmp/" + productProfileImage.name, function(err, currentImage) {
            if (currentImage.width() > MAX_SIZE || currentImage.height() > MAX_SIZE) {
                var rr = currentImage.width() > currentImage.height();
                var newWidth = rr ? MAX_SIZE : Math.floor(currentImage.width() * (MAX_SIZE / currentImage.height()));
                var newHeight = rr ? Math.floor(currentImage.height() * (MAX_SIZE / currentImage.width())) : MAX_SIZE;
                console.log('Old size: ' + currentImage.width() + ' x ' + currentImage.height());
                console.log('New size: ' + newWidth + ' x ' + newHeight);
                currentImage.batch()
                    .resize(newWidth, newHeight)
                    .writeFile("/tmp/resized.jpg", function(err) {
                        var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                                productProfileImage.originalname, "/tmp/resized.jpg");
                        console.log("Query (Media): " + mediaQuery);
                        pgclient.query(mediaQuery, function(err, results) {
                            callback(err);
                        });
                    });
            } else {
                var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                         productProfileImage.originalname, "/tmp/" + productProfileImage.name);
                console.log("Query (Media): " + mediaQuery);
                pgclient.query(mediaQuery, function(err, results) {
                    callback(err);
                });
            }
        });
    }

    var query = escape("INSERT INTO data VALUES(%L, 'FoodProduct', %L, 'now', 'now', 'file_load');", id,
                            JSON.stringify(newValue));
    queryFunctions.push(function(callback) {
        console.log("Query (FoodProduct): " + query);
        pgclient.query(query, function(err, results) {
            callback(err, results);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err) {
                req.flash('error', JSON.stringify(err));
            } else {
                req.flash('message', 'New Food Created');
            }
            res.redirect('/');
    });
});

app.post('/user', function(req, res) {
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
    newValue["active"] = 1;
    newValue["removed"] = 0;
    newValue["synchronized"] = 1;

    if (undefined == newValue["fullName"] || newValue["fullName"].trim().length == 0) {
        req.flash("error", "Name cannot be empty");
        res.redirect('/');
        return;
    }

    var queryFunctions = [];
    if (undefined != req.files && undefined != req.files["profileImage"]) {
        var profileImageFile = req.files["profileImage"];
        newValue["profileImage"] = profileImageFile.originalname;

        var deleteQuery = escape("DELETE FROM media WHERE filename = %L", profileImageFile.originalname);
        queryFunctions.push(function(callback) {
            console.log("Query (Media): " + deleteQuery);
            pgclient.query(deleteQuery, function(err, results) {
                callback(err);
            });
        });

        // obtain an image object:
        lwip.open("/tmp/" + profileImageFile.name, function(err, currentImage) {
            if (currentImage.width() > MAX_SIZE || currentImage.height() > MAX_SIZE) {
                var rr = currentImage.width() > currentImage.height();
                var newWidth = rr ? MAX_SIZE : Math.floor(currentImage.width() * (MAX_SIZE / currentImage.height()));
                var newHeight = rr ? Math.floor(currentImage.height() * (MAX_SIZE / currentImage.width())) : MAX_SIZE;
                console.log('Old size: ' + currentImage.width() + ' x ' + currentImage.height());
                console.log('New size: ' + newWidth + ' x ' + newHeight);
                currentImage.batch()
                    .resize(newWidth, newHeight)
                    .writeFile("/tmp/resized.jpg", function(err) {
                        var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                                profileImageFile.originalname, "/tmp/resized.jpg");
                        console.log("Query (Media): " + mediaQuery);
                        pgclient.query(mediaQuery, function(err, results) {
                            callback(err);
                        });
                    });
            } else {
                var mediaQuery = escape("INSERT INTO media VALUES(%L, (SELECT bytea_import(%L)), 'file_load');",
                                         profileImageFile.originalname, "/tmp/" + profileImageFile.name);
                console.log("Query (Media): " + mediaQuery);
                pgclient.query(mediaQuery, function(err, results) {
                    callback(err);
                });
            }
        });
    }

    var toSave = JSON.stringify(newValue);
    var query = escape("INSERT INTO data VALUES(%L, 'User', %L, 'now', 'now', 'file_load');", id, toSave);
    queryFunctions.push(function(callback) {
        console.log("Query (User): " + query);
        pgclient.query(query, function(err, results) {
            callback(err, results);
        });
    });

    async.waterfall(
        queryFunctions,
        function (err, result) {
            if (err) {
                req.flash('error', JSON.stringify(err));
            } else {
                req.flash('message', 'New User Profile Created');
            }
            res.redirect('/');
    });
})

// Load food / user
app.get('/food/:id', function(req, res) {
    req.flash('currentSelectedTab', '1');

    console.log("Param: " + req.params.id);
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
                var editObject = JSON.parse(row.value);

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
                res.render('edit', { message: editObject.name, action: '/food/' + req.params.id,
                        obj: sortObjectByKey(editObject, foodKeys), editKeys: foodKeys, titles: foodTitles });
            });
        }
    ],
        function (err, result) {
            console.log('End');
    });
});

app.get('/user/:id', function(req, res) {
    req.flash('currentSelectedTab', '0');

    console.log("Param: " + req.params.id);
    pgclient.query("SELECT value FROM data WHERE id = '" + req.params.id + "';", function(err, result) {
        if(err || result.rows.length == 0) {
            return console.error('error running query', err);
        }

        console.log("Result: " + result.rows[0].value);
        var editObject = JSON.parse(result.rows[0].value);
        res.render('edit', { message: editObject.fullName, action: '/user/' + req.params.id,
            obj: sortObjectByKey(editObject, userKeys), editKeys: userKeys, titles: userTitles });
    });
});

// Update food / user
app.post('/food/:id', function(req, res) {
    updateValue(req, res, false);
});

app.post('/user/:id', function(req, res) {
    updateValue(req, res, false);
});


app.post('/reports', function(req, res) {
    console.log('Body: ' + JSON.stringify(req.body));

    var args = ['--database=nasadb', '--user=postgres'];
    if (req.body.radioReport == "0") {
        if (undefined != req.body.users && req.body.users.length > 0) {
            var users = req.body.users instanceof Array ? req.body.users : new Array(req.body.users);
            args.push('--selected=' + users.join(","));
        } else {
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
        if (err) throw err;
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
    console.log('Files: ' + JSON.stringify(req.files));
    if (undefined != req.files && !isEmpty(req.files)) {
        var functions = [];
        if (undefined != req.files['userFileImport']) {
            functions.push(function(callback) {
               var userFileImport = req.files['userFileImport'];
               var path = userFileImport['path'];
               var args = ['--database=nasadb', '--user=postgres', '--filename=' + path];
                PythonShell.run('loadUser.py', {
                    args: args,
                    mode: 'text',
                    pythonPath: '/usr/bin/python',
                    scriptPath: __dirname
                }, function (err, results) {
                    //console.log("User results: " + results);
                    callback(err);
                });
            });

        }
        if (undefined != req.files['foodFileImport']) {
            functions.push(function(callback) {
               var foodFileImport = req.files['foodFileImport'];
                var path = foodFileImport['path'];
                var args = ['--database=nasadb', '--user=postgres', '--filename=' + path];
                PythonShell.run('loadFood.py', {
                    args: args,
                    mode: 'text',
                    pythonPath: '/usr/bin/python',
                    scriptPath: __dirname
                }, function (err, results) {
                    //console.log("Food results: " + results.length);
                    callback(err);
                });
            });
        }

        async.waterfall(
            functions,
            function (err, result) {
                if (err) {
                    req.flash('error', JSON.stringify(err));
                } else {
                    req.flash('message', 'Bulk Upload Successful');
                }
                res.redirect('/');
        });
    } else {
        req.flash('error', 'No file selected');
        res.redirect('/');
    }
});

// Delete food/user
app.get('/delete/food/:id', function(req, res) {
    req.flash('currentSelectedTab', '1');
    updateValue(req, res, true);
});

app.get('/delete/user/:id', function(req, res) {
    req.flash('currentSelectedTab', '0');
    updateValue(req, res, true);
});

pg.connect(conString, function(err, client, done) {
    if(err) {
        return console.error('error fetching client from pool', err);
    }
    pgclient = client;
    server = app.listen(8080, function() {
        console.log('Listening on port %d', server.address().port);
    });
});

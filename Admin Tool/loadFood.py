#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os, uuid
from datetime import datetime, date, timedelta

def xstr(s):
    return "" if s is None else str(s)

def remove_values_from_list(the_list, val):
   return [value for value in the_list if not value.startswith(val)]

def copyValue(fromFood, toFood, key):
    value = fromFood.get(key)
    if value is not None:
        toFood[key] = fromFood[key]
    return toFood

def checkCategories(cur, categories):
    result = []
    categoriesList = xstr(categories).split(";")

    for cat in categoriesList:
        data = {}
        id = uuid.uuid4()
        data[u"synchronized"] = 1
        data[u"value"] = cat
        data[u"removed"] = 0
        cur.execute("INSERT INTO data VALUES(%s, 'StringWrapper', %s, 'now', 'now', 'file_load');", (str(id), json.dumps(data)))
        result.append(str(id))

    cur.execute("COMMIT;")

    return ";".join(result)

try:
    optlist, args = getopt.getopt(sys.argv[1:], 'u:d:f:', ["filename=", "user=", "database="])

    user = None
    database  = None
    filename = None
    for o, a in optlist:
        if o in ("-u", "--user"):
            user = a
        elif o in ("-d", "--database"):
            database = a
        elif o in ("-f", "--filename"):
            filename = a
        else:
            assert False, "unhandled option"

    if filename is None:
        assert False, "Filename cannot be null"

    # Connect to an existing database
    conn = psycopg2.connect("dbname=" + database + " user=" + user + " host=127.0.0.1")
    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Query the database and obtain data as Python objects
    cur.execute("SELECT id, name, value FROM data WHERE name = 'FoodProduct';")
    foods = []
    for record in cur:
        obj = json.loads(record[2])
        obj[u"id"] = record[0]
        foods.append(obj)

    # Read file to load
    with open(filename, 'rb') as f:
        reader = csv.reader(f)
        try:
            next(reader, None)  # skip the headers
            food = {}
            for row in reader:
                rowLen = len(row)
                if rowLen < 12:
                    continue

                foodName = xstr(row[0]).strip()
                origin = xstr(row[2]).strip()
                if not foodName or not origin:
                    continue

                food[u"name"] = foodName
                food[u"categories"] = checkCategories(cur, row[1].strip())
                food[u"origin"] = origin
                food[u"barcode"] = row[3].strip()
                food[u"fluid"] = float(row[4])
                food[u"energy"] = float(row[5])
                food[u"sodium"] = float(row[6])
                food[u"protein"] = float(row[7])
                food[u"carb"] = float(row[8])
                food[u"fat"] = float(row[9])
                food[u"productProfileImage"] = row[10].strip()
                food[u"removed"] = 1 if row[11].strip() == "YES" else 0
                food[u"active"] = 1
                food[u"synchronized"] = 1

                foodMatch = next((l for l in foods if l.get(u"name","").strip() == foodName and l.get(u"origin","").strip() == origin), None)
                if foodMatch is None:
                    found = False
                    id = None
                    while not found:
                        id = uuid.uuid4()
                        cur.execute("SELECT id FROM data WHERE id = '{0}'".format(str(id)))
                        found = cur.rowcount == 0
                    data = json.dumps(food)
                    cur.execute("INSERT INTO data VALUES(%s, 'FoodProduct', %s, 'now', 'now', 'file_load');", (str(id), data))
                else:
                    food = copyValue(foodMatch, food, u"images")
                    food = copyValue(foodMatch, food, u"quantity")
                    food = copyValue(foodMatch, food, u"consumptionRecord")
                    data = json.dumps(food)
                    cur.execute("UPDATE data SET value = %s, modifieddate = 'now', modifiedby = 'file_load' WHERE id = %s;", (data, foodMatch[u"id"]))

            cur.execute("COMMIT;")
        except csv.Error as e:
            sys.exit('file %s, line %d: %s' % (filename, reader.line_num, e))

    cur.execute("COMMIT;")

    # Close communication with the database
    cur.close()
    conn.close()
except getopt.GetoptError as err:
    # print help information and exit:
    print(err) # will print something like "option -a not recognized"

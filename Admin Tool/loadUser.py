#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os, uuid
from datetime import datetime, date, timedelta

def xstr(s):
    return "" if s is None else str(s)

def copyValue(fromUser, toUser, key):
    value = fromUser.get(key)
    if value is not None:
        toUser[key] = fromUser[key]
    return toUser

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
    cur.execute("SELECT id, name, value FROM data WHERE name = 'User';")
    users = []
    for record in cur:
        obj = json.loads(record[2])
        obj[u"id"] = record[0]
        users.append(obj)

    # Read file to load
    with open(filename, 'rb') as f:
        reader = csv.reader(f)
        try:
            next(reader, None)  # skip the headers
            for row in reader:
                if len(row) == 0:
                    continue

                user = {}
                user[u"fullName"] = row[0].strip()
                user[u"admin"] = 0 if row[1].strip() == "NO" else 1
                user[u"dailyTargetFluid"] = float(row[2])
                user[u"dailyTargetEnergy"] = float(row[3])
                user[u"dailyTargetSodium"] = float(row[4])
                user[u"dailyTargetProtein"] = float(row[5])
                user[u"dailyTargetCarb"] = float(row[6])
                user[u"dailyTargetFat"] = float(row[7])
                user[u"maxPacketsPerFoodProductDaily"] = int(row[8])
                user[u"profileImage"] = ""
                user[u"useLastUsedFoodProductFilter"] = 0 if row[10].strip() == "NO" else 1
                user[u"weight"] = float(row[11])
                user[u"removed"] = 0
                user[u"synchronized"] = 1

                userMatch = next((l for l in users if l[u"fullName"].strip() == user[u"fullName"]), None)
                if userMatch is None:
                    found = False
                    id = None
                    while not found:
                        id = uuid.uuid4()
                        cur.execute("SELECT id FROM data WHERE id = '{0}'".format(str(id)))
                        found = cur.rowcount == 0
                    data = json.dumps(user)
                    cur.execute("INSERT INTO data VALUES(%s, 'User', %s, 'now', 'now', 'file_load');", (str(id), data))
                else:
                    user = copyValue(userMatch, user, u"consumptionRecord")
                    user = copyValue(userMatch, user, u"adhocFoodProduct")
                    user = copyValue(userMatch, user, u"lastUsedFoodProductFilter")
                    print(user)
                    data = json.dumps(user)
                    cur.execute("UPDATE data SET value = %s, modifieddate = 'now', modifiedby = 'file_load' WHERE id = %s;", (data, userMatch[u"id"]))

            cur.execute("COMMIT;")
        except csv.Error as e:
            cur.close()
            conn.close()
            sys.exit('file %s, line %d: %s' % (filename, reader.line_num, e))

    cur.execute("COMMIT;")

    # Close communication with the database
    cur.close()
    conn.close()
except getopt.GetoptError as err:
    # print help information and exit:
    print(err) # will print something like "option -a not recognized"

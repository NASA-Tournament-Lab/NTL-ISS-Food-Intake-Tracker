#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os
import zipfile, shutil, uuid

from datetime import datetime, date, timedelta
from uuid import UUID

def getOrigin(cursor, origin):
    cursor.execute("SELECT uuid FROM origin WHERE value = %s", (origin,))
    data = cursor.fetchone()
    return data[0] if data else None

def getUserId(userId, userMap):
    if userId is not None:
        if userMap[userId] != userId:
            print 'Changig id to ' + userMap[userId] + ' for id ' + userId
        return userMap[userId]
    return None

def getCategories(cur1, cur2, categories_str):
    category_uuids = []
    categories = categories_str.split(";") if categories_str else []
    for category in categories:
        cur1.execute("SELECT value FROM data WHERE name = 'StringWrapper' and id = %s", (category,))
        data = cur1.fetchone()
        obj = json.loads(data[0])

        cur2.execute("SELECT uuid FROM category WHERE value = %s", (obj[u"value"],))
        data = cur2.fetchone()
        category_uuids.append("\"" + data[0] + "\"")

    return "[" + ",".join(category_uuids) + "]" if category_uuids else "[]"

def getVoiceFilename(cursor, voice_uuid):
    cursor.execute("SELECT value FROM data WHERE name = 'StringWrapper' and id = %s", (voice_uuid,))
    data = cursor.fetchone()
    obj = json.loads(data[0])
    return obj.get(u"value", None)

def checkFoodExists(cursor, food_uuid):
    cursor.execute("SELECT uuid FROM food_product WHERE uuid = %s", (food_uuid,))
    return cursor.fetchone() is not None

def checkUserExists(cursor, fullName):
    cursor.execute("SELECT uuid FROM nasa_user WHERE full_name = %s", (fullName,))
    return cursor.fetchone()

def insertMediaRecord(cur2, food_record_uuid, media_uuid):
    media_record_uuid = str(uuid.uuid4())
    cur2.execute("INSERT INTO media_record VALUES(%s, %s, %s)", (media_record_uuid, media_uuid, food_record_uuid))

def insertMedia(cur1, cur2, imageFilename):
    if imageFilename is None:
        return None

    cur1.execute("SELECT data FROM media WHERE filename = %s", (imageFilename,))
    data = cur1.fetchone()
    if data is None:
        return None

    image_media_uuid = str(uuid.uuid4())

    print "Inserting file: " + imageFilename
    cur2.execute("INSERT INTO media VALUES(%s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'false', 'true')", (image_media_uuid, imageFilename, data,))

    return image_media_uuid

def insertFoodConsumptionRecord(cur1, cur2, userMap):
    cur1.execute("SELECT id, value FROM data WHERE name = 'FoodConsumptionRecord' ORDER BY modifieddate ASC")
    foodArray = cur1.fetchall()

    for cur_record in foodArray:
        obj = json.loads(cur_record[1])

        iid = cur_record[0].lower()
        carb = obj[u"carb"]
        fat = obj[u"fat"]
        energy = obj[u"energy"]
        protein = obj[u"protein"]
        sodium = obj[u"sodium"]
        fluid = obj[u"fluid"]
        adhoc_only = obj[u"adhocOnly"] == 1
        quantity = obj[u"quantity"]
        comments = obj[u"comment"]
        timestamp = obj[u"timestamp"]
        food_product_uuid = obj.get(u"foodProduct", None)
        user_uuid = getUserId(obj.get(u"user", None), userMap)
        removed = obj[u"removed"] == 1
        synchronized = True

        if not removed and checkFoodExists(cur2, food_product_uuid):
            print "Inserting food record: " + iid
            cur2.execute("INSERT INTO food_product_record VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", (iid, carb, fat, energy, protein, sodium, fluid, adhoc_only, quantity, comments, timestamp, food_product_uuid, user_uuid, removed, synchronized,))

            voiceRecordings = obj.get(u"voiceRecordings", None)
            if voiceRecordings:
                for voiceRecording in voiceRecordings.split(";"):
                    filename = getVoiceFilename(cur1, voiceRecording)
                    voice_uuid = insertMedia(cur1, cur2, filename)
                    insertMediaRecord(cur2, iid, voice_uuid)
        else:
            print "Ignoring food record with id: " + iid

def insertFood(cur1, cur2, userMap):
    cur1.execute("SELECT id, value FROM data WHERE name in ('AdhocFoodProduct','FoodProduct') ORDER BY name, modifieddate ASC")
    foodArray = cur1.fetchall()

    for cur_record in foodArray:
        obj = json.loads(cur_record[1])

        iid = cur_record[0].lower()
        active = obj[u"active"] == 1
        barcode = obj[u"barcode"]
        carb = obj[u"carb"]
        energy = obj[u"energy"]
        fat = obj[u"fat"]
        fluid = obj[u"fluid"]
        protein = obj[u"protein"]
        sodium = obj[u"sodium"]
        name = obj[u"name"]
        quantity = 1
        user_uuid = getUserId(obj.get(u"user", None), userMap)
        origin_uuid = getOrigin(cur2, obj.get(u"origin", None))
        category_uuids = getCategories(cur1, cur2, obj.get(u"categories", None))
        removed = obj[u"removed"] == 1
        synchronized = True

        image_media_uuid = insertMedia(cur1, cur2, obj[u"productProfileImage"])

        origin = obj.get(u"origin", "None")
        print "Inserting food: " + name + " with origin " + (origin if origin else "None")
        cur2.execute("INSERT INTO food_product VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", (iid, active, barcode, carb, energy, fat, fluid, protein, sodium, name, quantity, user_uuid, origin_uuid, image_media_uuid, category_uuids, removed, synchronized,))

def insertUser(cur1, cur2):
    cur1.execute("SELECT id, value FROM data WHERE name = 'User' ORDER BY modifieddate ASC")
    userArray = cur1.fetchall()

    for cur_record in userArray:
        obj = json.loads(cur_record[1])

        iid = cur_record[0].lower()
        admin = obj[u"admin"] == 1
        carb = obj[u"dailyTargetCarb"]
        fat = obj[u"dailyTargetFat"]
        energy = obj[u"dailyTargetEnergy"]
        protein = obj[u"dailyTargetProtein"]
        sodium = obj[u"dailyTargetSodium"]
        fluid = obj[u"dailyTargetFluid"]
        full_name = obj[u"fullName"]
        packets_per_day = obj[u"maxPacketsPerFoodProductDaily"]
        use_last_filter = obj[u"useLastUsedFoodProductFilter"] == 1
        weight = obj[u"weight"]
        removed = obj[u"removed"] == 1
        synchronized = True

        print "Migrating: " + full_name

        image_media_uuid = insertMedia(cur1, cur2, obj[u"profileImage"])

        checkUser = checkUserExists(cur2, full_name)
        if checkUser is not None:
            checkUserUUID = checkUser[0]
            userMap[iid] = checkUserUUID
        else:
            cur2.execute("INSERT INTO nasa_user VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", (iid, admin, carb, fat, energy, protein, sodium, fluid, full_name, packets_per_day, use_last_filter, weight, image_media_uuid, removed, synchronized,))
            userMap[iid] = iid

try:
    optlist, args = getopt.getopt(sys.argv[1:], 'u:d:p:h:t', ["user=", "database=", "password=", "host=", "port="])

    user = None
    password = None
    database  = None
    host  = None
    port  = None
    for o, a in optlist:
        if o in ("-u", "--user"):
            user = a
        elif o in ("-d", "--database"):
            database = a
        elif o in ("-p", "--password"):
            password = a
        elif o in ("-h", "--host"):
            host = a
        elif o in ("-t", "--port"):
            port = a
        else:
            assert False, "unhandled option"

    # Connect to an existing database
    conn1 = psycopg2.connect("dbname=" + database + " user=" + user + " password=" + password + " host=" + host+ " port=" + port + " sslmode=require")
    # Open a cursor to perform database operations
    cur1 = conn1.cursor()

    # Connect to an existing database
    conn2 = psycopg2.connect("dbname=pl_fit_new user=" + user + " password=" + password + " host=" + host+ " port=" + port + " sslmode=require")
    # Open a cursor to perform database operations
    cur2 = conn2.cursor()

    userMap = {}

    try:
        cur2.execute("TRUNCATE TABLE food_product_record CASCADE;")
        cur2.execute("TRUNCATE TABLE media_record CASCADE;")
        cur2.execute("TRUNCATE TABLE media CASCADE;")
        cur2.execute("TRUNCATE TABLE food_product CASCADE;")
        cur2.execute("TRUNCATE TABLE nasa_user CASCADE;")
        conn2.commit()

        # insert nasa users
        insertUser(cur1, cur2)
        # insert food products
        insertFood(cur1, cur2, userMap)
        # insert food consumption records
        insertFoodConsumptionRecord(cur1, cur2, userMap)

        conn2.commit()
    except psycopg2.Error as e:
        conn1.close()
        conn2.close()
        exc_info = sys.exc_info()
        raise exc_info[1], None, exc_info[2]

except getopt.GetoptError as err:
    # print help information and exit:
    print(err) # will print something like "option -a not recognized"
    exc_info = sys.exc_info()
    raise exc_info[1], None, exc_info[2]

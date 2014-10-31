#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os
from datetime import datetime, date, timedelta
import zipfile, shutil

def xstr(s):
    return "" if s is None else str(s)

def zipdir(path, zip):
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            zip.write(os.path.join(root, dir))
        for file in files: 
            zip.write(os.path.join(root, file), os.path.join(root, file), zipfile.ZIP_DEFLATED)

try:
    optlist, args = getopt.getopt(sys.argv[1:], 's:e:u:d:', ["user=", "database=","selected="])

    user = None
    database  = None
    startDate = None
    endDate = None
    selected = None
    for o, a in optlist:
        if o in ("-u", "--user"):
            user = a
        elif o in ("-d", "--database"):
            database = a
        elif o == "-s":
            startDate = a
        elif o == "-e":
            endDate = a
        elif o == "--selected":
            selected = a
        else:
            assert False, "unhandled option"

    if startDate is None:
        sDate = datetime.strptime("19700101", "%Y%m%d")
        eDate = datetime.combine(datetime.utcnow().date() + timedelta(1), datetime.min.time())
    else:
        sDate = datetime.strptime(startDate, "%Y%m%d")
        if endDate is None:
            eDate = datetime.combine(sDate + timedelta(1), datetime.min.time())
        else:
            eDate = datetime.strptime(endDate, "%Y%m%d")

    os.chdir("./reports")

    initialDirectory = sDate.strftime("%Y%m%d") + "_" + eDate.strftime("%Y%m%d")
    if not os.path.exists(initialDirectory):
        os.makedirs(initialDirectory)
    os.chdir(initialDirectory)

    # Connect to an existing database
    conn = psycopg2.connect("dbname=" + database + " user=" + user + " host=127.0.0.1")
    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Query the database and obtain data as Python objects
    cur.execute("SELECT id, name, value FROM data WHERE name in ('User', 'AdhocFoodProduct', 'FoodProduct', 'FoodConsumptionRecord');")
    users = []
    foods = []
    records = []
    for record in cur:
        obj = json.loads(record[2])
        obj[u"id"] = record[0]
        if record[1] == "User":
            if selected is None:
                users.append(obj)
            elif obj[u"id"] in selected.split(','):
                users.append(obj)
        elif record[1] in ("FoodProduct", "AdhocFoodProduct"):
            foods.append(obj)
        elif record[1] == "FoodConsumptionRecord" and obj[u"removed"] == 0:
            timestamp = datetime.strptime(obj[u"timestamp"][:-6], "%Y-%m-%d %H:%M:%S")
            if timestamp >= sDate and timestamp < eDate: # select only records inside this date
                records.append(obj)

    # Query the database and obtain data as Python objects
    cur.execute("SELECT filename, data FROM media;")
    medias = []
    for media in cur:
        mediaObj = {}
        mediaObj[u"filename"] = media[0]
        mediaObj[u"data"] = media[1]
        medias.append(mediaObj)

    # Loop over all users in database
    for user in users:
        # Create directories - if necessary
        directory = user[u"fullName"]
        if not os.path.exists(directory):
            os.makedirs(directory)
        os.chdir(directory)

        directory = "media"
        if not os.path.exists(directory):
            os.makedirs(directory)

        # Create summary.csv file
        myfile = open("summary.csv", "w")
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)

        # Create header
        wr.writerow(["Username", "Date Time", "Food Product", "Quantity", "Comments", "Images", "Voices"])

        recordMatch = (l for l in records if l[u"user"] == user[u"id"])
        for record in recordMatch:
            food = next((l for l in foods if l[u"id"] == record[u"foodProduct"]), None)
            row = []
            row.append(user[u"fullName"])
            row.append(record[u"timestamp"])
            row.append(food[u"name"])
            row.append(record[u"quantity"])
            row.append(xstr(record.get(u"comment", "")) .replace ("\n", " "))

            imagesToSave = []
            for image in filter(None, record.get(u"images", "").split(";")):
                cur.execute("SELECT value FROM data WHERE id='" + image + "';")
                obj = json.loads(cur.fetchone()[0])
                match = next((l for l in medias if l[u"filename"] == obj[u'value']), None)
                open("media/" + match[u"filename"], 'wb').write(str(match[u"data"]))
                imagesToSave.append(match[u"filename"])
            row.append(";".join(imagesToSave))

            voicesToSave = []
            for voice in filter(None, record.get(u"voiceRecordings", "").split(";")):
                cur.execute("SELECT value FROM data WHERE id='" + voice + "';")
                obj = json.loads(cur.fetchone()[0])
                match = next((l for l in medias if l[u"filename"] == obj[u'value']), None)
                open("media/" + match[u"filename"], 'wb').write(str(match[u"data"]))
                voicesToSave.append(match[u"filename"])
            row.append(";".join(voicesToSave))

            wr.writerow(row)
        myfile.close()
        os.chdir("../")

    os.chdir("../")

    os.remove('summary.zip')

    # Close communication with the database
    cur.close()
    conn.close() 

    zipf = zipfile.ZipFile('summary.zip', 'w')
    zipdir(initialDirectory, zipf)
    zipf.printdir()
    zipf.close()

    shutil.rmtree(initialDirectory)
except getopt.GetoptError as err:
    # print help information and exit:
    print(err) # will print something like "option -a not recognized"



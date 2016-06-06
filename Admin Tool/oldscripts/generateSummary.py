#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os
from datetime import datetime, date, timedelta
import zipfile, shutil

def xstr(s):
    return "" if s is None else s.encode('utf-8')

def zipdir(path, zip):
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            zip.write(os.path.join(root, dir))
        for file in files:
            zip.write(os.path.join(root, file), os.path.join(root, file), zipfile.ZIP_DEFLATED)

try:
    optlist, args = getopt.getopt(sys.argv[1:], 's:e:u:d:p:h:t', ["user=", "database=", "password=", "host=", "port=", "selected="])

    user = None
    password = None
    database  = None
    host  = None
    port  = None
    startDate = None
    endDate = None
    selected = None
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
        eDate = datetime.combine(datetime.utcnow().date() + timedelta(180), datetime.min.time())
    else:
        sDate = datetime.strptime(startDate, "%Y%m%d")
        if endDate is None:
            eDate = datetime.combine(sDate + timedelta(180), datetime.min.time())
        else:
            eDate = datetime.strptime(endDate, "%Y%m%d")

    os.chdir("./reports")

    initialDirectory = sDate.strftime("%Y%m%d") + "_" + eDate.strftime("%Y%m%d")
    if not os.path.exists(initialDirectory):
        os.makedirs(initialDirectory)
    os.chdir(initialDirectory)

    # Connect to an existing database
    conn = psycopg2.connect("dbname=" + database + " user=" + user + " password=" + password + " host=" + host+ " port=" + port)
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
        removed = obj.get(u"removed", None)
        if removed is None:
            continue
        if record[1] == "User" and removed == 0:
            if selected is None:
                users.append(obj)
            elif obj[u"id"] in selected.split(','):
                users.append(obj)
        elif record[1] in ("FoodProduct", "AdhocFoodProduct"):
            name = obj.get(u"name", None)
            if name is not None:
                foods.append(obj)
        elif record[1] == "FoodConsumptionRecord" and removed == 0:
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
        fullName = xstr(user[u"fullName"]).strip()
        if not fullName:
            continue

        # Create directories - if necessary
        fullNameAscii = fullName.decode("utf-8").encode("ascii", "replace")
        directory = fullNameAscii.replace("/", "_")
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

        recordMatch = (l for l in records if l.get(u"user","") == user[u"id"])
        for record in recordMatch:
            food = next((l for l in foods if l[u"id"] == record.get(u"foodProduct", "")), None)
            if food is None:
                print "No food found for user " + user[u"fullName"] + " at " + record[u"timestamp"]
                continue
            try:
                row = []
                row.append(fullName)
                row.append(record[u"timestamp"][:-6])
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
            except Exception as err:
                myfile.close()
                exc_info = sys.exc_info()
                raise exc_info[1], None, exc_info[2]

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
    exc_info = sys.exc_info()
    raise exc_info[1], None, exc_info[2]
except psycopg2.Error as e:
    exc_info = sys.exc_info()
    raise exc_info[1], None, exc_info[2]


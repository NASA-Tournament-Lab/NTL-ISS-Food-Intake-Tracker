#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os
from datetime import datetime, date, timedelta
import zipfile, shutil

def xstr(s):
    return "" if s is None else s.encode('utf-8')

def xarray(s):
    if s is None:
       return []
    else:
       return s.split(',')

def zipdir(path, zip):
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            zip.write(os.path.join(root, dir))
        for file in files:
            zip.write(os.path.join(root, file), os.path.join(root, file), zipfile.ZIP_DEFLATED)

try:
    optlist, args = getopt.getopt(sys.argv[1:], 's:e:u:d:p:h:t', ["user=", "database=", "password=", "host=", "port=", "selected=", "output="])

    user = None
    password = None
    database  = None
    host  = None
    port  = None
    startDate = None
    endDate = None
    selected = None
    destPath = None
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
        elif o == "--output":
            destPath = a
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
    conn = psycopg2.connect("dbname=" + database + " user=" + user + " password=" + password + " host=" + host+ " port=" + port + " sslmode=require")
    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Loop over all users in database
    selectedArray = []
    if selected is None:
        cur.execute("SELECT uuid, full_name FROM nasa_user;")
        selectedArray = cur.fetchall()
    else:
        for user in selected.split(','):
            cur.execute("SELECT uuid, full_name FROM nasa_user WHERE uuid = %s", (user,))
            selectedArray.append(cur.fetchone())
    
    for cur_user in selectedArray:
        user = cur_user[0]
        fullName = xstr(cur_user[1]).strip()
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

        cur.execute("SELECT timestamp, name, quantity, comments, images, voicerecordings FROM summary_view WHERE uuid = %s AND timestamp BETWEEN %s AND %s", (user, sDate, eDate))
        record = {}
        for cur_record in cur:
            record[u"timestamp"] = cur_record[0]
            record[u"food_name"] = cur_record[1]
            record[u"quantity"] = cur_record[2]
            record[u"comments"] = xstr(cur_record[3])
            record[u"images"] = xarray(cur_record[4])
            record[u"voicerecordings"] = xarray(cur_record[5])

            try:
                row = []
                row.append(fullName)
                row.append(record[u"timestamp"].strftime("%Y-%m-%d %H:%M:%S"))
                row.append(record[u"food_name"])
                row.append(record[u"quantity"])
                row.append(record[u"comments"])

                imagesToSave = []
                for image in filter(None, record[u"images"]):
                    cur.execute("SELECT filename, data FROM media WHERE uuid = %s", (xstr(image),))
                    match = cur.fetchone()
                    open("media/" + match[0], 'wb').write(str(match[1]))
                    imagesToSave.append(match[0])
                row.append(";".join(imagesToSave))

                voicesToSave = []
                for voice in filter(None, record[u"voicerecordings"]):
                    cur.execute("SELECT filename, data FROM media WHERE uuid = %s", (xstr(voice),))
                    match = cur.fetchone()
                    open("media/" + match[0], 'wb').write(str(match[1]))
                    voicesToSave.append(match[0])
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
  
    if destPath is not None:
        shutil.copy2('summary.zip', destPath)    

    shutil.rmtree(initialDirectory)
except getopt.GetoptError as err:
    # print help information and exit:
    print(err) # will print something like "option -a not recognized"
    exc_info = sys.exc_info()
    raise exc_info[1], None, exc_info[2]
except psycopg2.Error as e:
    exc_info = sys.exc_info()
    raise exc_info[1], None, exc_info[2]


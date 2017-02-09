#!/usr/bin/python

from requests.auth import HTTPBasicAuth
from requests.packages.urllib3.exceptions import InsecureRequestWarning

import getopt, sys, os, time, csv
import requests
import ConfigParser

def configSectionMap(Config, section):
    dict1 = {}
    options = Config.options(section)
    for option in options:
        try:
            dict1[option] = Config.get(section, option)
            if dict1[option] == -1:
                print("skip: %s" % option)
        except:
            print("exception on %s!" % option)
            dict1[option] = None
    return dict1

def getFile(dict):
    if dict is not None:
        return dict['filename']
    else:
        return None

def checkCsv(filename):
    csvFile = open(filename, 'rb')
    error = False
    try:
        dialect = csv.Sniffer().sniff(csvFile.read(1024 * 1024))
    except csv.Error:
        error = True
    finally:
        csvFile.close()

    if error:
        print 'File ' + filename + ' is not a csv file'
        exit(1)

class SendFiles:
    configFile = None
    configObject = None
    foodFile = None
    userFile = None
    userImageFile = None
    executedFolder = None
    clear = 'off'

    def parse(self):
        optlist, args = getopt.getopt(sys.argv[1:], 'c:f')
        self.configFile = 'config.ini'
        for o, a in optlist:
            if o in ('-c'):
                self.configFile = a
            elif o in ('-f'):
                self.clear = 'on'
            else:
                assert False, "unhandled option"

        if not os.path.exists(self.configFile):
            assert False, "config file does not exists"

    def configure(self):
        configObject = ConfigParser.ConfigParser()
        configObject.read(self.configFile)

        try:
            self.network = configSectionMap(configObject, 'Network')
            self.foodFile = getFile(configSectionMap(configObject, 'Food'))
            self.userFile = getFile(configSectionMap(configObject, 'User'))
            self.userImageFile = getFile(configSectionMap(configObject, 'UserImage'))

            self.executedFolder = configSectionMap(configObject, 'Executed')['folder']
        except Exception, e:
            print 'Configuration error: ' + str(e)
            exit(1)

    def closeFiles(self, files):
        for key, file in files.iteritems():
            # close the file first
            if isinstance(file, tuple):
                file[1].close()
            else:
                file.close()

    def backup(self, files):
        for key, file in files.iteritems():
            # close the file first
            if isinstance(file, tuple):
                fileToUse = file[1]
            else:
                fileToUse = file

            # get name
            fileName = fileToUse.name
            # get extension
            root, ext = os.path.splitext(fileName)
            # build new file name
            name = key + '_' + time.strftime("%Y%m%d%H%M%S") + ext
            newFileName = os.path.join(self.executedFolder, name)
            # move file
            os.rename(fileName, newFileName)
            print 'moved ' + fileName +  ' to ' + newFileName

    def execute(self):
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

        url = self.network['base']+ '/import'
        username = self.network['username']
        password = self.network['password']
        files = {}

        # check for executed folder exists
        if self.executedFolder is None or not os.path.exists(self.executedFolder):
            print 'Executed Folder must exist'
            exit(1)

        # check for food file
        if self.foodFile is not None and os.path.exists(self.foodFile):
            checkCsv(self.foodFile)
            files['foodFileImport'] = ('Food.csv', open(self.foodFile, 'r'), 'text/csv')
        # check for user file
        if self.userFile is not None and os.path.exists(self.userFile):
            checkCsv(self.userFile)
            files['userFileImport'] = ('User.csv', open(self.userFile, 'r'), 'text/csv')
            # check for user image file
            if self.userImageFile is not None and os.path.exists(self.userImageFile):
                files['userImageFileImport'] = ('UserImage.zip', open(self.userImageFile, 'rb'), 'application/zip')

        if not files:
            print 'No files to import'
            exit(0)

        r = requests.post(url,
                    files=files,
                    data={ 'clear': self.clear, 'script': 'on' },
                    verify=False,
                    auth=(username, password))

        if r.status_code > 299:
            print r.text
            exit(1)

        resp = r.json()

        self.closeFiles(files)
        if r.status_code == 200 and resp['success']:
            print 'Files were imported successfully'
            self.backup(files)
            exit(0)
        else:
            print 'Files were NOT imported: ' + resp['error']
            exit(1)

if __name__ == "__main__":
    sendFiles = SendFiles()
    sendFiles.parse()
    sendFiles.configure()
    sendFiles.execute()

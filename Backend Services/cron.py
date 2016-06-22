#! /usr/bin/python

import getopt, sys, psycopg2, json, csv, os, ConfigParser
from crontab import CronTab	
from datetime import datetime, date, timedelta
import zipfile, shutil

def ConfigSectionMap(section):
    dict1 = {}
    options = Config.options(section)
    for option in options:
        try:
            dict1[option] = Config.get(section, option)
            if dict1[option] == -1:
                DebugPrint("skip: %s" % option)
        except:
            print("exception on %s!" % option)
            dict1[option] = None
    return dict1
    
Config = ConfigParser.ConfigParser()
Config.read("/home/app/pl_fit/report/config.ini")

Crontab=ConfigSectionMap("Crontab")
current_user=Crontab['current_user']
base_path=Crontab['base_path']
output_path=Crontab['path']
users=Crontab['users']
schedule=Crontab['schedule']

Crontab=ConfigSectionMap("Database")
host=Crontab['host']
port=Crontab['port']
user=Crontab['user']
password=Crontab['password']
database=Crontab['database']

users_cron = CronTab(user=True)

args = " --host " + host + " --port " + port + " --user " + user + " --password " + password + " --database " + database + " --output " + output_path
selected = None
if users != '*':
        args = args + ' --selected "' + users + '"'

job  = users_cron.new(command="cd " + base_path + "/NTL-ISS-Food-Intake-Tracker-master/Backend\ Services/issfit-api && ./generateSummary.py" + args, comment="SUMMARY")
if schedule == 'weekly':
        print 'using weekly'
        job.setall('0 0 * * 0')
elif schedule == 'hourly':
        print 'using hourly'
        job.setall('0 * * * *')
elif schedule == 'monthly':
        print 'using monthly'
        job.setall('0 0 1 * *')
else:
     assert False, "unknown schedule"

users_cron.write()


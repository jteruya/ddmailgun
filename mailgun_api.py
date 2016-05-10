from email.utils import parsedate
import datetime
import time
import csv
import json
import requests
import subprocess
import os

from re import sub
from os import chdir, system
from sys import argv
from time import sleep

def get_logs(starttime, endtime):
  return requests.get(
    'https://api.mailgun.net/v2/doubledutch.me/events',
    #auth = ('api', 'key-62l8msi5u0g6engufpmi8g-tev7gz480'),
    auth = ('api', 'key-57a576d7be1f223e908154aacccf5f8f'),
    params = {
      'begin': str(starttime),
      'end': str(endtime),
      'ascending': 'yes',
      'event': 'clicked',
      'limit': '300'
    }
  )

def get_next_logs(api):
  return requests.get(
    api,
    #auth = ('api', 'key-62l8msi5u0g6engufpmi8g-tev7gz480'),
    auth = ('api', 'key-57a576d7be1f223e908154aacccf5f8f'), 
    params = {
      'ascending': 'yes',
      'limit': '300'
    }
  )

def create_alias(string):
# Removes special characters and spaces from a string for a name alias, i.e. for directory names.q
  return sub('[^A-Za-z0-9 ]','',string).replace(' ','_').lower()

def load_database(alias, directory):
  cpy = '''drop table if exists ''' + alias + ''';
  create table ''' + alias + '''
  ( campaignid text,
    name text,
    timestamp timestamp,
    recipient text,
    event text,
    uservars text
  );
  copy ''' + alias + '''
  from \'''' + directory + '/' + alias + '''.csv\'
  delimiter \',\'
  csv;
  '''

  print 'Running following SQL script:\n'
  print cpy

  with open(alias+'.sql', 'w') as f:
    f.write(cpy)

  system('cat ' + directory + '/' + alias + '.sql | psql -U anguyen -d dev')

def main():

  # Set Initial Variables
  #home = '/home/jteruya'
  home = os.path.expanduser('~') 
  app = 'mailgun_load'  
  wd = home + '/' + app
  csvd = wd + '/csv/'
  parsed_csvd = wd + '/parsed_csv/' 
  pg_connect = 'psql -h 10.223.192.6 -p 5432 -A -t analytics etl'
  schema_name = 'mailgun'
  db_table_name = 'mailgun_unsubscribe'
  

  # Set Working Directory of Script
  chdir(wd)

  # Get Start Date 
  #start_date = argv[1]
  start_date = subprocess.check_output(pg_connect + ' -c "select coalesce(max(cast(to_timestamp(timestamp_epoch) as date)),\'2015-01-01\') from ' + schema_name + '.' + db_table_name + '"', shell = True).split("\n",1)[0]

  # Delete Table from Start Date
  subprocess.call(pg_connect + ' -c "delete from ' + schema_name + '.' + db_table_name + ' where cast(to_timestamp(timestamp_epoch) as date) >= \'' + start_date + '\'"', shell = True)

  # Convert Start Date to Epoch 
  date_pattern = '%Y-%m-%d'
  tz = subprocess.check_output(["date","+%Z"]).split("\n",1)[0]
  start_datetime_epoch = int(time.mktime(time.strptime(start_date, date_pattern)))

  # Calculate End Date (Current Date - 60 Minutes)
  datetime_pattern = '%Y-%m-%d %H:%M:%S'
  current_datetime = datetime.datetime.now() 
  end_datetime = current_datetime - datetime.timedelta(minutes = 60)
  end_datetime = end_datetime.strftime(datetime_pattern)
  end_datetime_epoch = int(time.mktime(time.strptime(end_datetime, datetime_pattern)))

  # Output Starting Message 
  print "Starting Mailgun API Pull on " + current_datetime.strftime(datetime_pattern) + "..." 
  print "API Pull Start Date: " + start_date + " 00:00:00 " + tz + ", Epoch Start Date: " + str(start_datetime_epoch)  
  print "API Pull End Date: " + end_datetime + " " + tz + ", Epoch End Date: " + str(end_datetime_epoch) + "\n"

  # initialize log retrieval
  pge = 1
  jsonresult = json.loads(get_logs(start_datetime_epoch, end_datetime_epoch).content)
  log = jsonresult['items']
  nextresults = str(jsonresult['paging']['next']) 
  #print "Next Result Page: " + nextresults + "\n" 
  tot = len(log)

  print "Results Page: " + str(pge) + ", Results Count: " + str(tot) 
 
  while tot > 0:
     if pge > 1:
        sleep(15)
        jsonresult = json.loads(get_next_logs(nextresults).content)
        log = jsonresult['items']
        nextresults = str(jsonresult['paging']['next'])
        tot = len(log)
        print "Results Page: " + str(pge) + ", Results Count: " + str(tot)

     with open('csv/click_events_results_pg_' + str(pge) + '_' + current_datetime.strftime(date_pattern) + '.csv', 'w') as f:
        w = csv.writer(f, delimiter = ',')

        for l in log:
           record = [l['recipient'], l['message']['headers']['message-id'], l['id'], l['event'], l['url'], str(l['timestamp']).split(".",1)[0]]
           w.writerow(record)

     pge = pge + 1 

  # Final Output File
  output_file = 'unsubscribe_click_events_results_' + current_datetime.strftime(date_pattern) + '.csv'

  # Get Unsubscribe Click Events
  subprocess.call('grep -h unsubscribe ' + csvd + 'click_events_results_pg*' + current_datetime.strftime(date_pattern) + '* > ' + parsed_csvd + output_file, shell = True) 

  print "\n"
  print "Created Output File: " + output_file

  # Load into DB 
  subprocess.call(pg_connect + ' -c "\\copy ' + schema_name + '.' + db_table_name + ' from \'' + parsed_csvd + output_file + '\' delimiter \',\' csv header"', shell = True)

  print "Loaded into Table: " + schema_name + "." + db_table_name

  process_end_datetime = datetime.datetime.now()

  print "Process Complete on " + process_end_datetime.strftime(datetime_pattern) + "\n\n"
 
if __name__ == '__main__':
  main()

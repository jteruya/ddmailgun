#!/bin/bash

# --------------------------------------------------------------------------------------------
# Quick script to read form the MailGun endpoint and load to a target table (mailgun.events)
# --------------------------------------------------------------------------------------------

# Input Param
from=$1
to=$2

# Build out the CURL call and where it will land
mgpwd=$HOME/mailgun_load
base='https://activityfeed.doubledutch.me/email/events?'
#base='https://green-activityfeed.doubledutch.me/email/events?'
land=$mgpwd'/land/land_'$1'_'$2

full_curl='curl -XGET "'$base'from='$from'&to='$to'"'

# Run the CURL call and dump to file
echo 'Executing: '$full_curl
echo 'Landing to: '$land

eval $full_curl | grep -v "12345678-AAAA-BBBB-CCCC-ABCDEFGHIJKL" | grep -v "testAppId" | grep -v "testAppId2" > $land

# Delete the previously loaded data for that timestamp range
psql -h 10.183.144.118 -p 5432 -U etl -c "DELETE FROM mailgun.mailgun_events WHERE EventTimestamp BETWEEN "$from" AND "$to";" analytics 

# Load the file
psql -h 10.183.144.118 -A -p 5432 -U etl -F',' -c "\COPY mailgun.mailgun_events FROM '"$land"' DELIMITER ',' CSV HEADER;" analytics 

echo "done."

# --------------------------------------------------------------------------------------------

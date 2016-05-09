#!/bin/bash

# --------------------------------------------------------------------------------------------
# Quick script to read form the MailGun endpoint and load to a target table (mailgun.events)
# --------------------------------------------------------------------------------------------

# Input Param
from=$1
to=$2

# Build out the CURL call and where it will land
mgpwd=$HOME/mailgun_load
base='https://greenactivityfeed.doubledutch.me/email/events?'
land=$mgpwd'/land/land_'$1'_'$2

full_curl='curl -XGET "'$base'from='$from'&to='$to'"'

# Run the CURL call and dump to file
echo 'Executing: '$full_curl
echo 'Landing to: '$land

eval $full_curl | grep -v "12345678-AAAA-BBBB-CCCC-ABCDEFGHIJKL" | grep -v "testAppId" | grep -v "testAppId2" > $land

# Delete the previously loaded data for that timestamp range
psql -h 10.223.176.157 -p 5432 -U jteruya -c "DELETE FROM mailgun.events WHERE EventTimestamp BETWEEN "$from" AND "$to";" dev

# Load the file
psql -h 10.223.176.157 -A -p 5432 -U jteruya -F',' -c "\COPY mailgun.events FROM '"$land"' DELIMITER ',' CSV HEADER;" dev

echo "done."

# --------------------------------------------------------------------------------------------

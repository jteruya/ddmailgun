#!/bin/bash

# --------------------------------------------------------------------------------------------
# Quick script to read form the MailGun endpoint and load to a target table (mailgun.events)
# --------------------------------------------------------------------------------------------

# Input Param
from=$1
to=$2

# Build out the CURL call and where it will land
mgpwd=$HOME/mailgun_load
#base='https://activityfeed.doubledutch.me/email/events?'
base='https://green-activityfeed.doubledutch.me/email/events?'
land=$mgpwd'/land/land_'$1'_'$2

full_curl='curl -XGET "'$base'from='$from'&to='$to'"'

# Run the CURL call and dump to file
echo 'Executing: '$full_curl
echo 'Landing to: '$land

eval $full_curl | grep -v "12345678-AAAA-BBBB-CCCC-ABCDEFGHIJKL" | grep -v "testAppId" | grep -v "testAppId2" > $land

# Delete the previously loaded data for that timestamp range
psql -h 10.208.97.116 -p 5432 -U analytics -c "DELETE FROM public.mailgun_events WHERE EventTimestamp BETWEEN "$from" AND "$to";" etl

# Load the file
psql -h 10.208.97.116 -A -p 5432 -U analytics -F',' -c "\COPY public.mailgun_events FROM '"$land"' DELIMITER ',' CSV HEADER;" etl

echo "done."

# --------------------------------------------------------------------------------------------

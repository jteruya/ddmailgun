#!/bin/bash

# --------------------------------------------------------------------------------------------
# Quick script to read form the MailGun endpoint and load to a target table (mailgun.events)
# --------------------------------------------------------------------------------------------

# Input Param
from=$1
to=$2

# Build out the CURL call and where it will land
pwd=$(eval pwd)
base='https://greenactivityfeed.doubledutch.me/email/events?'
land=$pwd'/land/land_'$1'_'$2

full_curl='curl -XGET "'$base'from='$from'&to='$to'"'

# Run the CURL call and dump to file
echo 'Executing: '$full_curl
echo 'Landing to: '$land

eval $full_curl > $land

# Delete the previously loaded data for that timestamp range
psql -h 10.223.176.157 -p 5432 -U kchiou -c "DELETE FROM mailgun.events WHERE EventTimestamp BETWEEN "$from"000 AND "$to"000;" dev

# Load the file
psql -h 10.223.176.157 -A -p 5432 -U kchiou -F',' -c "\COPY mailgun.events FROM '"$land"' DELIMITER ',' CSV HEADER;" dev

echo "done."

# --------------------------------------------------------------------------------------------
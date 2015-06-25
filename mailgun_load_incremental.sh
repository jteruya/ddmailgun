#!/bin/bash

# ------------------------------------------------------------------------------------------------------------
# Mailgun Load (Incremental)
# Schedule this job in order for it to perform the "catch up" from the last loaded time to the current time. 
# ------------------------------------------------------------------------------------------------------------

# Identify the latest timestamp in the mailgun.events table
max_epoch=$(psql -h 10.208.97.116 -p 5432 -A -t -U analytics -c "SELECT MAX(EventTimestamp) FROM public.mailgun_events" etl)

# Identify the current timestamp and convert to epoch
curr_epoch=$(date +"%s%3N")

# Perform the mailgun load for the date range identified
$HOME/mailgun_load/./mailgun_load.sh $max_epoch $curr_epoch

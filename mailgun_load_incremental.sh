#!/bin/bash

# Identify the latest timestamp in the mailgun.events table
max_epoch=$(psql -h 10.223.176.157 -p 5432 -A -t -U kchiou -c "SELECT MAX(EventTimestamp) FROM mailgun.events" dev)

# Identify the current timestamp and convert to epoch
curr_epoch=$(date +"%s%3N")

# Perform the mailgun load for the date range identified
$HOME/mailgun_load/./mailgun_load.sh $max_epoch $curr_epoch
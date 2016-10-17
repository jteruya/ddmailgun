#!/bin/bash

# ------------------------------------------------------------------------------------------------------------
# Mailgun Load (Incremental)
# Schedule this job in order for it to perform the "catch up" from the last loaded time to the current time. 
# ------------------------------------------------------------------------------------------------------------

# Identify the latest timestamp in the mailgun.events table
max_epoch=$(psql -h 10.183.144.118 -p 5432 -A -t -U etl -c "SELECT MAX(EventTimestamp) FROM mailgun.mailgun_events" analytics)

# Identify the current timestamp and convert to epoch
curr_epoch=$(date +"%s%3N")

# Perform the mailgun load for the date range identified
#$HOME/mailgun_load/./mailgun_load.sh $max_epoch $curr_epoch
$HOME/mailgun_load/./mailgun_load_wrapper.sh $max_epoch $curr_epoch

# Insert and update data into mailguncube 
psql -h 10.183.144.118 -A -p 5432 -U etl -f "/home/etl/mailgun_load/sql/mailguncube_etl.sql" analytics

# Insert and update mailgun aggregate tables 
psql -h 10.183.144.118 -A -p 5432 -U etl -f "/home/etl/mailgun_load/sql/mailgun_agg_etl.sql" analytics

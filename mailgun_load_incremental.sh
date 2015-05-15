#!/bin/bash

# Identify the latest timestamp in the mailgun.events table


# Identify the current timestamp and convert to epoch
curr_epoch=$(date +"%s")

# Perform the mailgun load for the date range identified
# ./mailgun_load $start $curr_epoch
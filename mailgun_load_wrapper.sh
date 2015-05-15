#!/bin/bash

# Using input parameters for the range to load, loads 15 minute segments into our target table

# Assign the input parameters
start=$1
end=$2

# Identify the starting point
start15=$start

# Loop via 15 minute increments
while [ $start15 -lt $end ]
do	

	starttime=$(date -r $start15 '+%m/%d/%Y:%H:%M:%S')
	end15=$[$start15+900]
	endtime=$(date -r $end15 '+%m/%d/%Y:%H:%M:%S')

	# Load for that segment
	echo "Loading from "$starttime" to "$endtime"."
	./mailgun_load.sh $start15 $end15

	# Increment for the next piece
	start15=$end15
	
done

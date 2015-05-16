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

	end15=$[$start15+900000]
	start15_milli=$[$start15/1000]
	echo $start15_milli
	starttime=$(date -d @"$start15_milli")
	endtime=$(date -d @"$end15")

	# Load for that segment
	echo "Loading from "$starttime" to "$endtime"."
	# $HOME/mailgun_load/./mailgun_load.sh $start15 $end15

	# Increment for the next piece
	start15=$end15
	
done

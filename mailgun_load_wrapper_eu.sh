#!/bin/bash

# ------------------------------------------------------------------------------------------------------------
# Mailgun Load (Adhoc)
# Using input parameters for the range to load, loads 15 minute segments into our target table
# ------------------------------------------------------------------------------------------------------------

# Assign the input parameters
start=$1
end=$2

# Identify the starting point
start15=$start

# Loop via 15 minute increments
while [ $start15 -lt $end ]
do	

	#end15=$[$start15+900000]
        end15=$[$start15+300000]

	start15_milli=$[$start15/1000]
	end15_milli=$[$end15/1000]
	
	starttime=$(date -d @"$start15_milli")
	endtime=$(date -d @"$end15_milli")

	# Load for that segment
	echo "Loading from "$starttime" to "$endtime"."
	$HOME/mailgun_load/./mailgun_load.sh $start15 $end15

	# Increment for the next piece
	start15=$end15
	
done

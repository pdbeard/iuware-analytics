#!/bin/bash

# If exists, moves cday image to pday image.
  cdayImage="/Applications/Processing.app/Contents/Java/data/cday.png" 
  if [ -f $cdayImage ];
  then
    cp /Applications/Processing.app/Contents/Java/data/cday.png /Applications/Processing.app/Contents/Java/data/pday.png
    rm /Applications/Processing.app/Contents/Java/data/cday.png
  fi

# Creates csv file with correct headers
	echo "lon,lat,sess" > /Applications/Processing.app/Contents/Java/data/shapes/cDay_IUware_data.csv

# Appends data to csv file and saves it into correct directory 
# When running processing-java on command line, it searches for data in the Java directory for some reason. (rename to cDay_IUware_data.csv)
	python analytics_query.py >> /Applications/Processing.app/Contents/Java/data/shapes/cDay_IUware_data.csv

# Run processing script for current day
	processing-java --sketch=/Users/digitalsign/Desktop/sos_iuware/processing_iuware_latlon/ --output=./test2 --run --force

# Run processing script for previous day (script increases opacity) 
	#processing-java --sketch=/Users/digitalsign/Desktop/sos_iuware/processing_iuware_latlon_pDay/ --output=./test2 --run --force

# Moves cday.png into global data directory 
	cp /Users/digitalsign/Desktop/sos_iuware/processing_iuware_latlon/cday.png /Applications/Processing.app/Contents/Java/data/shapes/cday.png
  rm /Users/digitalsign/Desktop/sos_iuware/processing_iuware_latlon/cday.png

# Run script that merges current day, previous day, and bg map
	processing-java --sketch=/Users/digitalsign/Desktop/sos_iuware/processing_merge/ --output=./test2 --run --force

######
#  # Move or delete previous day into backup folder named yesterdays date 
#    #rm /Applications/Processing.app/Contents/Java/data/shapes/pDay_IUware_data.csv
#
#  # Rename current day data to previous day data (pday_IUware_data.csv)
#    #cp /Applications/processing.app/Contents/Java/data/shapes/cDay_IUware_data.csv /Applications/Processing.app/Contents/Java/data/shapes/pDay_IUware_data.csv
#    #rm /Applications/Processing.app/Contents/Java/data/shapes/cDay_IUware_data.csv
#
#######

# Counter for Image Sequence File names
	COUNTER_FILE="counter.tmp"
	MAX_FILE="max.tmp"
	count='cat $COUNTER_FILE'
	max='cat $MAX_FILE'

	cp /Users/digitalsign/Desktop/sos_iuware/processing_merge/merge.png /Users/digitalsign/Desktop/sos_iuware/processing_merge/${count}.png

	# Push to SOS
	scp /Users/digitalsign/Desktop/sos_iuware/processing_merge/${count}.png sos@sos-primary.avl.indiana.edu:/shared/sos/media/site-custom/IU_ware/images
 
	if [$count > $max]
	then 
		echo "0" >counter.tmp	
	else 
		((count++))
	fi
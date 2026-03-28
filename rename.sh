#!/bin/bash
# exit if pipeline fails or unset variables
set -eu

# default values
: "${METEOR_NORAD:=57166 59051}"
: "${SATNOGS_OUTPUT_PATH:=/tmp/.satnogs/data}"

ID="$2"      # $2 observation ID
TLE="$4"     # $4 used tle's
DATE="$5"    # $5 timestamp Y-m-dTH-M-S

IMAGE="$SATNOGS_OUTPUT_PATH/data_${ID}"

SATNAME=${TLE#*tle0\": \"}
SATNAME=${SATNAME%%\"*}
NORAD=${TLE#*tle2\": \"2 }
NORAD=${NORAD%% *}

if [[ " ${METEOR_NORAD} " =~ .*\ ${NORAD}\ .* ]]; then
    echo "RENAME: $ID, Norad: $NORAD, Sat: $SATNAME"  
    cd "${SATNOGS_OUTPUT_PATH}/meteor/MSU-MR (Filled)"
    # Find all .png files and rename them
    for file in *.png; do
      if [ -f "$file" ]; then
        new_name="${IMAGE}_${file}"
        mv "$file" "$new_name"
        echo "$file → $new_name"
      fi
    done
fi

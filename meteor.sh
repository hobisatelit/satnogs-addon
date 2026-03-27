#!/bin/bash
# exit if pipeline fails or unset variables
set -eu

# default values
: "${METEOR_NORAD:=57166 59051}"
: "${SATNOGS_OUTPUT_PATH:=/tmp/.satnogs/data}"
: "${IQ_DUMP_FILENAME:=/iq/iq}"
: "${SATDUMP_APP_DIR:=/iq/app/satdump}"

export LD_LIBRARY_PATH=$SATDUMP_APP_DIR

# Launch with: {command} {{ID}} {{FREQ}} {{TLE}} {{TIMESTAMP}} {{BAUD}} {{SCRIPT_NAME}}
# /iq/app/satnogs-post 13665238 137900000 '{"tle0": "METEOR M2-3", "tle1": "1 57166U 23091A   26084.83747850 -.00000009  00000-0  14817-4 0  9997", "tle2": "2 57166  98.6179 141.4862 0004884  62.5359 297.6316 14.24039267142657"}' 2026-03-26T01:59:49 40000 satnogs_fsk.py

ID="$2"      # $2 observation ID
TLE="$4"     # $4 used tle's
DATE="$5"    # $5 timestamp Y-m-dTH-M-S
BAUD="$6"    # $6 baudrate

# Extract satellite name and NORAD
SATNAME=${TLE#*tle0\": \"}
SATNAME=${SATNAME%%\"*}
NORAD=${TLE#*tle2\": \"2 }
NORAD=${NORAD%% *}

echo "INFO: $ID, Norad: $NORAD, Sat: $SATNAME, Baud: $BAUD, TLE: $TLE" 

if [[ " $METEOR_NORAD " =~ .*\ ${NORAD}\ .* && "$ENABLE_IQ_DUMP" ]]; then
    rm -rf "${SATNOGS_OUTPUT_PATH}/meteor"
    mkdir -p "${SATNOGS_OUTPUT_PATH}/meteor"
    sleep 5
    cp $IQ_DUMP_FILENAME "${IQ_DUMP_FILENAME}-meteor.raw"
    cd $SATDUMP_APP_DIR
    ./satdump meteor_m2-x_lrpt baseband "${IQ_DUMP_FILENAME}-meteor.raw" "${SATNOGS_OUTPUT_PATH}"/meteor --samplerate 160000 --baseband_format s16 --fill_missing --max_fill_lines 100
fi

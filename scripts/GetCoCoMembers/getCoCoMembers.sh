#!/bin/bash

# Check Args 
if [ -z "$1" ]; then
    echo "Please provide a list of CoCoNest Members to extract. e.g., 5 15 25 68 100"
    exit 1
fi
KLIST="$1"

# Source config 
source ../config.txt
source ~/.bashrc_sbci

mkdir -p $OUTPUT_FOLDER/labels

# Create Annot Files
module load matlab
matlab -nodesktop -nosplash -singleCompThread -r "CoCoNest2Annot('$PARC_NAME','$KLIST','$COCO_PATH'); exit;"
 
# Project Labels 
for k in $KLIST; do

    bash projectLabels.sh "${PARC_NAME}_${k}"

done


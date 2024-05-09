#!/bin/bash

source ../config.txt

module add matlab/2022b

##############################################
### Step 1: Create and Prune CoCoNest Tree ### 
##############################################

mkdir -p ../output/TreeResults

# ~3gb
step1_id=$(sbatch --parsable --job-name=Create_${PARC_NAME}_Job --ntasks=1 --mem=16g -t 2- --output=out_slurm/%J_${PARC_NAME}.out --wrap="matlab -nodesktop -nosplash -singleCompThread -r 'createPruneTree(\"$PARC_NAME\",\"$DATA_FILE\",\"$OUTPUT_FOLDER\",\"$LINKAGE\",\"$DISTANCE\",\"$TREE_ERROR\")'")

# Create list of all tree parcellations and add to external parcellations
TREE_PARCS=$(echo "${KSEQ}" | sed "s/[^ ]*/${PARC_NAME}_&/g")
ALL_PARCS="${TREE_PARCS} ${OUT_PARCS}"

#########################################
### Step 2: Create Data for Parc Eval ###
#########################################

mkdir -p ../output/ConData

for PARC in ${ALL_PARCS}; do
    sbatch --dependency=afterok:$step1_id --job-name=${PARC}_CreateParcData --ntasks=1 --mem=60g -t 6:00:00 --output=out_slurm/%J_CREATE_${PARC}_DATA.out --wrap="matlab -nodesktop -nosplash -singleCompThread -r \"createConDataHCP('$PARC','$OUTPUT_FOLDER')\""
done


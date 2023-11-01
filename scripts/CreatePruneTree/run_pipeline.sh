#!/bin/bash

source config.txt

# Step 1: Create and Prune CoCoNest Tree
module add matlab/2022b

mkdir -p ../output/TreeResults

# ~3gb
#sbatch --job-name=Create_${PARC_NAME}_Job --ntasks=1 --mem=16g -t 6:00:00 --output=out_slurm/%J_${PARC_NAME}.out --wrap="matlab -nodesktop -nosplash -singleCompThread -r 'createPruneTree(\"$PARC_NAME\",\"$DATA_FILE\",\"$OUTPUT_FOLDER\",\"$LINKAGE\",\"$DISTANCE\",\"$TREE_ERROR\")'"

### Step 2: Create Data for Parc Eval ###
#mkdir -p ../output/ParcTensors
#mkdir -p ../output/PCScores
#
## Tree Data
#for k in $KSEQ; do
#    sbatch --job-name=${PARC_NAME}_CreateParcData --ntasks=1 --mem=60g -t 6:00:00 --output=out_slurm/%J_CREATE_${PARC_NAME}_DATA.out --wrap="matlab -nodesktop -nosplash -singleCompThread -r \"createParcTensor('$PARC_NAME','$OUTPUT_FOLDER',$k)\""
#done
#
#### External Parc Data
#for o in $OUT_PARCS; do
#    sbatch --job-name=${o}_CreateParcData --ntasks=1 --mem=60g -t 6:00:00 --output=out_slurm/%J_CREATE_${o}_DATA.out --wrap="matlab -nodesktop -nosplash -singleCompThread -r \"createParcTensor('$o','$OUTPUT_FOLDER','')\""
#done


### Step 3: Predict Traits ### 
module add r
mkdir -p ../output/PredictResults

# Regression
#for t in $REG_TRAITS; do
#    for k in $KSEQ; do
#      sbatch --job-name=${PARC_NAME}_PredictOnTrait --output out_slurm/%J_${t}_${k}_${PARC_NAME}.out --time=3:00:00 --ntasks=1 --cpus-per-task=1 --mem-per-cpu=16G --wrap "Rscript PredictOnSplit.R \
#      trait='$t' task='regress' alpha='0' outFolder='$OUTPUT_FOLDER' parcName='$PARC_NAME' k='$k' "
#    done
#done

for t in $REG_TRAITS; do
    for o in $OUT_PARCS; do
      sbatch --job-name=${o}_PredictOnTrait --output out_slurm/%J_${t}_${o}.out --time=3:00:00 --ntasks=1 --cpus-per-task=1 --mem-per-cpu=16G --wrap "Rscript PredictOnSplit.R \
      trait='$t' task='regress' alpha='0' outFolder='$OUTPUT_FOLDER' parcName='$o' k='' "
    done
done

# Classification
#for t in $CLASS_TRAITS; do
#    for k in $KSEQ; do
#      sbatch --job-name=${PARC_NAME}_PredictOnTrait --output out_slurm/%J_${t}_${k}_${PARC_NAME}.out --time=3:00:00 --ntasks=1 --cpus-per-task=1 --mem-per-cpu=16G --wrap "Rscript PredictOnSplit.R \
#      trait='$t' task='classify' alpha='0' outFolder='$OUTPUT_FOLDER' parcName='$PARC_NAME' k='$k' "
#    done
#done

#for t in $CLASS_TRAITS; do
#    for o in $OUT_PARCS; do
#      sbatch --job-name=${o}_PredictOnTrait --output out_slurm/%J_${t}_${o}.out --time=3:00:00 --ntasks=1 --cpus-per-task=1 --mem-per-cpu=16G --wrap "Rscript PredictOnSplit.R \
#      trait='$t' task='classify' alpha='0' outFolder='$OUTPUT_FOLDER' parcName='$o' k='' "
#    done
#done


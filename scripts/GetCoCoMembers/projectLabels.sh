#!/bin/bash
source ../config.txt
LABEL_IN=$1

echo $LABEL_IN

## Change to Freesurfer Subjects Directory ##
export SUBJECTS_DIR=$FS_SUB_FOLDER

for hemi in {L,R}; do

    ### Convert .annot files to label.gii
    mris_convert --annot $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fslr32k.annot $COCO_PATH/scripts/data/spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fslr32k.label.gii

    ### Project to fsaverage 
    wb_command -label-resample $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fslr32k.label.gii $COCO_PATH/scripts/data/spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii $COCO_PATH/scripts/data/spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii BARYCENTRIC $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fsaverage.label.gii

    ### Adjust hemisphere naming for mri_surf2surf
    if [ "$hemi" == "L" ]; then
        fs_hemi="lh"
    else
        fs_hemi="rh"
    fi

    
    mris_convert --annot $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fsaverage.label.gii $COCO_PATH/scripts/data/spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii  $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fsaverage.annot

    ### Project to MNI 
    mri_surf2surf --srcsubject fsaverage --trgsubject mni_152_sym_09c --sval-annot $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_fsaverage.annot --tval $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_mni152.annot --mapmethod nnf --hemi ${fs_hemi}

    cp $OUTPUT_FOLDER/labels/${hemi}_${LABEL_IN}_mni152.annot $FS_SUB_FOLDER/mni_152_sym_09c/label/${fs_hemi}.${LABEL_IN}_mni152.annot
done

mri_aparc2aseg --s mni_152_sym_09c --annot ${LABEL_IN}_mni152 --o $OUTPUT_FOLDER/labels/${LABEL_IN}_mni152.mgz

rm ${OUTPUT_FOLDER}/labels/L_${LABEL_IN}_mni152.annot
rm ${OUTPUT_FOLDER}/labels/R_${LABEL_IN}_mni152.annot



rm temp_k.txt


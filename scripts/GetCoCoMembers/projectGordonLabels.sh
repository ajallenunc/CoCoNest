#!/bin/bash
source ../config.txt

## Change to Freesurfer Subjects Directory ##
export SUBJECTS_DIR=/nas/longleaf/home/aallen1/freesurfer/subjects

for hemi in {L,R}; do

    ### Convert .annot files to label.gii
    mris_convert --annot $OUTPUT_FOLDER/labels/${hemi}.Gordon_fslr32k_labels.annot $COCO_PATH/scripts/data/spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii $OUTPUT_FOLDER/labels/${hemi}_Gordon_fslr32k.label.gii

    ### Project to fsaverage 
    wb_command -label-resample $OUTPUT_FOLDER/labels/${hemi}_Gordon_fslr32k.label.gii $COCO_PATH/scripts/data/spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii $COCO_PATH/scripts/data/spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii BARYCENTRIC $OUTPUT_FOLDER/labels/${hemi}_Gordon_fsaverage.label.gii

    ### Adjust hemisphere naming for mri_surf2surf
    if [ "$hemi" == "L" ]; then
        fs_hemi="lh"
    else
        fs_hemi="rh"
    fi

    
    mris_convert --annot $OUTPUT_FOLDER/labels/${hemi}_Gordon_fsaverage.label.gii $COCO_PATH/scripts/data/spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii  $OUTPUT_FOLDER/labels/${hemi}_Gordon_fsaverage.annot


done



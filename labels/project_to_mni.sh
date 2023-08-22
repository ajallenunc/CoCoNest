#!/bin/bash

LABEL_IN=$1

## Change to Freesurfer Subjects Directory ##
export SUBJECTS_DIR=/nas/longleaf/home/aallen1/freesurfer/subjects

mkdir -p output 

for hemi in {L,R}; do

    ### Convert .annot files to label.gii
    mris_convert --annot my_labels/${hemi}.${LABEL_IN}.annot spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii output/${hemi}_${LABEL_IN}.label.gii

    ### Project to fsaverage 
    wb_command -label-resample output/${hemi}_${LABEL_IN}.label.gii spheres/S1200.${hemi}.sphere.32k_fs_LR.surf.gii spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii BARYCENTRIC output/${hemi}_${LABEL_IN}_fsaverage.label.gii

    ### Adjust hemisphere naming for mri_surf2surf
    if [ "$hemi" == "L" ]; then
        fs_hemi="lh"
    else
        fs_hemi="rh"
    fi

    
    mris_convert --annot output/${hemi}_${LABEL_IN}_fsaverage.label.gii spheres/fs_${hemi}-to-fs_LR_fsaverage.${hemi}_LR.spherical_std.164k_fs_${hemi}.surf.gii  output/${hemi}_${LABEL_IN}_fsaverage.annot

    ### Project to MNI 
    mri_surf2surf --srcsubject fsaverage --trgsubject mni_152_sym_09c --sval-annot output/${hemi}_${LABEL_IN}_fsaverage.annot --tval output/${hemi}_${LABEL_IN}_mni152.annot --mapmethod nnf --hemi ${fs_hemi}

done



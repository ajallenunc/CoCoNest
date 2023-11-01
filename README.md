# CoCoNest
A nested, multi-resolution family of parcellations of the human cerebral cortex. The CoCoNest family was from the structural connectivity of 897 participants from the Human Connectome Project. The average structural connectivity from these subjects was fed into a standard agglomerative clustering algorithm to create a full binary tree, and then a error-complexity pruning algorithm to create a decreasing sequence of subtrees. The terminal nodes of each subtree corresponds to a unique member of the CoCoNest family. 

<img src="imgs/parc_pipeline.png" width="600">

Scripts to recreate the ConConNest family are available in the scripts/CreatePruneTree folder. 

ConConNest was originally created on the MSM mesh (the same mesh used to create the HCP-MMP1 atlas). Below is an example of the CoCoNest-250 pparcellation upsampled to the fsaverage space

<img src="imgs/conconnest_250_fsavg.png" width="300">

and projected to MNI space. 

<img src="imgs/conconnest_250_mni.png" width="600">

# Extracting Members of the CoCoNest family
All members of the CoCoNest family are available in the original downsampled MSM space and can be accessed using the scripts/util/tree2IDX.m function along with the scripts/output/TreeResults/CoCoNest_prune_struct.mat file. This matrix file contains the relevant data, collected during the tree growing and pruning algorithms, needed to extract CoCoNest members of different sizes. 

Additionally, the scripts in the scripts/GetCoCoMembers folder can be used to extract members of the CoCoNest family and project these members to the fsaverage and MNI space. A brief example is given below. 

*Note: To project CoCoNest members to different template spaces using the below code, you must install [Freesurfer](https://surfer.nmr.mgh.harvard.edu/) and the [Connectome Workbench](https://www.humanconnectome.org/software/connectome-workbench) Additionally, to project members to the MNI space you must first run recon-all on the MNI-152 template volume image.*

First, we edit the scripts/config.txt file with the correct path to the CoCoNest directory. Then we can run the following code 
```
cd scripts/GetCoCoMembers
bash getCoCoMember.sh "5 15 68 100 150" 
```
This will create the relevant label files for the CoCoNest members with close to 5, 15, 68, 100, and 150 parcels in the scripts/output/labels directory. Example label files for CoCoNest-250 can also be found in scripts/output/labels

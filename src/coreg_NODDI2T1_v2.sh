#!/bin/bash
#register NODDI maps to T1 space
#Meaghan Perdue Oct. 2023

export WD=/Volumes/catherine_team/Trainee_Folders/mvperdue/preschool/multimodal/data
export T1w=/Volumes/catherine_team/Trainee_Folders/mvperdue/preschool/mrs/data_lag
export TEMPLATE=/Volumes/catherine_team/Trainee_Folders/mvperdue/preschool/multimodal/src/oasis_template
export NODDI=/Volumes/catherine_team/Trainee_Folders/Jess/NODDI/1_Normalized
#export NODDI2=/Volumes/catherine_team/Trainee_Folders/Bryce/Preschool_2022_NODDI_Outputs


cd $WD/${1}
# mkdir tmp
# cd tmp

# # Pull T1 from MRS folder, run ANTS N4 bias correction 
# N4BiasFieldCorrection \
#     -d 3 \
#     -i $T1w/*${1}*/s*.nii \
#     -s 2 \
#     -c [50x50x50x50,0.0000000001] \
#     -o ${1}_T1_N4.nii.gz

# # resample to 1mm iso voxels
# mrgrid ${1}_T1_N4.nii.gz regrid ${1}_T1_N4_1mm.nii.gz -voxel 1

# # run ANTS brain extraction following Jess Reynolds' NODDI prep protocol and OASIS templates
# cd $WD/${1}
# antsBrainExtraction.sh \
#     -d 3 -a tmp/${1}_T1_N4_1mm.nii.gz \
#     -e $TEMPLATE/T_template0.nii.gz \
#     -m $TEMPLATE/T_template0_BrainCerebellumProbabilityMask.nii.gz \
#     -f $TEMPLATE/T_template0_BrainCerebellumRegistrationMask.nii.gz \
#     -o ${1}_T1_N4_1mm_bet


# ANTS registration NODDI to T1 using 3-stage approach: rigid, affine, deformable syn 
# second pair of -m -f options will use the warp from the first 2, then run step 3 based on that registration
# this produced much better image alignment vs. the 2-stage rigid, affine method
# first, run registration using ODI map (better contrast than NDI)
# antsRegistrationSyN.sh \
#     -f ${1}_T1_N4_1mm_betBrainExtractionBrain.nii.gz \
#     -m $NODDI/2_ODI/${1}_fitted_odi.nii \
#     -x ${1}_T1_N4_1mm_betBrainExtractionMask.nii.gz \
#     -t s \
#     -o ${1}_ODI_reg2antsT1_N4_1mm_

# Apply transforms from ODI->T1 registration affine stage to NDI map 
antsApplyTransforms \
    -i $NODDI/2_NDI/${1}_fitted_ficvf.nii \
    -t ${1}_ODI_reg2antsT1_N4_1mm_0GenericAffine.mat \
    -r ${1}_T1_N4_1mm_betBrainExtractionBrain.nii.gz \
    -o tmp/${1}_NDI_reg2antsT1_N4_1mm_AffineWarped.nii.gz

# Run deformable syn registration step on NDI to complete registration to T1 space
antsRegistrationSyN.sh \
    -f ${1}_T1_N4_1mm_betBrainExtractionBrain.nii.gz \
    -m tmp/${1}_NDI_reg2antsT1_N4_1mm_AffineWarped.nii.gz \
    -x ${1}_T1_N4_1mm_betBrainExtractionMask.nii.gz \
    -t so \
    -o tmp/${1}_NDI_reg2antsT1_N4_1mm_


# Run registration directly on NDI map
# antsRegistrationSyN.sh \
#     -f ${1}_T1_N4_1mm_betBrainExtractionBrain.nii.gz \
#     -m $NODDI/2_NDI/${1}_fitted_ficvf.nii \
#     -x ${1}_T1_N4_1mm_betBrainExtractionMask.nii.gz \
#     -t s \
#     -o ${1}_NDI_reg2antsT1_N4_1mm_




### DON'T USE THESE NEWER MAPS, VOXELS DIMENSIONS DO NOT MATCH OLD NODDI MAPS
# #for newer NODDI data (2019-2021)
# for i in $(cat subjlist2.txt); do
#  	cd $WD/${1}
#  	antsRegistrationSyN.sh \
#         -f ${1}_T1_1mm_bet.nii.gz \
#         -m $NODDI2/${1}_fitted_odi.nii \
#         -t a \
#         -o ${1}_ODI_reg2T1_1mm_
#     antsApplyTransforms \
#     -i $NODDI2/${1}_fitted_ficvf.nii \
#     -t ${1}_ODI_reg2T1_1mm_0GenericAffine.mat \
#     -r ${1}_T1_1mm_bet.nii.gz \
#     -o ${1}_NDI_reg2T1_1mm_Warped.nii.gz
#     flirt -in ${1}_mrs_mask.nii.gz \
#         -ref ${1}_T1_1mm_bet.nii.gz \
#         -applyisoxfm 1.0 \
#         -nosearch \
#         -out ${1}_mrs_mask_1mm.nii.gz
#     fslmaths ${1}_mrs_mask_1mm.nii.gz -bin ${1}_mrs_mask_1mm.nii.gz
# done


# resample mrs voxel to 1mm voxel size and binarize
#cd $WD/${1}
# flirt -in ${1}_mrs_mask.nii.gz \
#     -ref ${1}_T1_1mm_bet.nii.gz \
#     -applyisoxfm 1.0 \
#     -nosearch \
#     -out ${1}_mrs_mask_1mm.nii.gz
# fslmaths ${1}_mrs_mask_1mm.nii.gz -bin ${1}_mrs_mask_1mm.nii.gz
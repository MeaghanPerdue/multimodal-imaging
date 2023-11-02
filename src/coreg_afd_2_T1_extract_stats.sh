#!/bin/bash
# register AFD maps to skull-stripped 1mm T1s from MaCRUISE
# extract AFD stats from LTP voxel

# Meaghan Perdue Oct. 2023
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4

export WD=~/Mirror/multimodal/data
export MRTRIX=~/Mirror/mrtrix_ss3tCSD/data

cd $WD/${1}
#mkdir tmp

# Convert AFD map to .nii.gz

# Register AFD map to ANTS BET 1mm T1 
echo "-------- Register qihMT map to T1 --------"
antsRegistrationSyN.sh \
    -f tmp/T1_N4Corrected_MAstrip_init.nii.gz \
    -m ${MRTRIX}/${2}/${3}/ss3t_csd/fixel_native/voxel_afd_mean_weighted.nii.gz \
    -x tmp/T1_N4Corrected_MAstrip_mask.nii.gz \
    -t s \
    -o ${1}_afd_reg2macruiseT1_ants_

# Apply transforms from AFD->T1 registration affine stage to Fiber Complexity map, rigid & affine steps 
### EXCLUDING FOR NOW, COMPLEXITY MAPS SEEM NOISY, HARD TO INTERPRET
# echo "------- Register Fiber Complexity map to T1: rigid, affine --------"
# antsApplyTransforms \
#     -i ${MRTRIX}/${2}/${3}/ss3t_csd/fixel_native/voxel_fiber_complexity.nii.gz \
#     -t ${1}_afd_reg2macruiseT1_ants_0GenericAffine.mat \
#     -r tmp/T1_N4Corrected_MAstrip_init.nii.gz \
#     -o tmp/${1}_complexity_reg2macruiseT1_AffineWarped.nii.gz

# Run deformable syn registration step on Fiber Complexity map to complete registration to T1 space
# echo "------- Register Fiber Complexity map to T1: SynB --------"
# antsRegistrationSyN.sh \
#     -f tmp/T1_N4Corrected_MAstrip_init.nii.gz \
#     -m tmp/${1}_complexity_reg2macruiseT1_N4_1mm_AffineWarped.nii.gz \
#     -x tmp/T1_N4Corrected_MAstrip_mask.nii.gz \
#     -t so \
#     -o ${1}_complexity_reg2macruiseT1_


# Prep stats output file
# first set up txt file header row
#echo study_code	subj_id ses_id    afd_ltp_m 	afd_ltp_sd >> ${WD}/AFD_LTP_1mm_M-SD_all.txt
	
# write qihMT mean and sd values from each mask into output file
echo ${1} ${2} ${3} $(fslstats ${1}_afd_reg2macruiseT1_ants_Warped.nii.gz -k ${1}_mrs_mask_1mm.nii.gz -M -S) >> ${WD}/AFD_LTP_1mm_M-SD_all.txt

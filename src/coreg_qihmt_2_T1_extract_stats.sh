#!/bin/bash
# Normalize and resample T1s to 1mm voxels, run brain extraction
# register qihMT and NODDI maps to 1mm T1s
# this scripts replaces old coreg_ihmt and coreg_NODDI scripts

# Meaghan Perdue Oct. 2023
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4

export WD=~/Projects/multimodal/data
#export TEMPLATE=~/Projects/multimodal/oasis_template
export MACRUISE='/Volumes/catherine_team/Project_Folders/MaCRUISE/PS_MaCRUISE1mm/1_Processed_Output'

cd $WD/${1}
#mkdir tmp

# Pull T1 1mm from MaCRUISE outputs
cp $MACRUISE/${2}_${3}/*1mm-x-MaCRUISE_v3/ToadsSeperate/MultiAtlasStripping/T1_N4Corrected_MAstrip_* tmp 
#use this path instead if the subject had edited macruise outputs *macruise_lebel_v3*
if [ ! -f filename $MACRUISE/${2}_${3}/*1mm-x-MaCRUISE_v3/ToadsSeperate/MultiAtlasStripping/T1_N4Corrected_MAstrip_init.nii.gz]
    then
    cp $MACRUISE/*_${1}_*/*macruise_lebel_v3*/ToadsSeperate/MultiAtlasStripping/T1_N4Corrected_MAstrip_ tmp
    fi
   
# Register qihMT map to ANTS BET 1mm T1 
echo "-------- Register qihMT map to T1 --------"
antsRegistrationSyN.sh \
    -f tmp/T1_N4Corrected_MAstrip_init.nii.gz \
    -m ${1}_qihMTMaskedThresh.nii.gz \
    -x tmp/T1_N4Corrected_MAstrip_mask.nii.gz \
    -t s \
    -o ${1}_qihMT_reg2macruiseT1_ants_

# resample mrs voxel to 1mm voxel size and binarize
echo "------- resample and binarize MRS voxel --------" 
flirt -in ${1}_mrs_mask.nii.gz \
    -ref tmp/T1_N4Corrected_MAstrip_init.nii.gz \
    -applyisoxfm 1.0 \
    -nosearch \
    -out ${1}_mrs_mask_1mm.nii.gz
fslmaths ${1}_mrs_mask_1mm.nii.gz -bin ${1}_mrs_mask_1mm.nii.gz


# Prep stats output file
# first set up txt file header row
#echo study_code	    qihmt_ltp_m 	qihmt_ltp_sd	 >> ${WD}/qihMT_LTP_1mm_M-SD_all.txt
	
# write qihMT mean and sd values from each mask into output file
echo ${1} $(fslstats ${1}_qihMT_reg2macruiseT1_ants_Warped.nii.gz -k ${1}_mrs_mask_1mm.nii.gz -M -S) >> ${WD}/qihMT_LTP_1mm_M-SD_all.txt

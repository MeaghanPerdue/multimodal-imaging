#!/bin/bash
#calculate mean qihMT values from voxels within MRS mask (white matter only and whole voxel)
# Meaghan Perdue 14 Nov 2022

# apply mask of white matter within MRS voxel to qihMT map and calculate mean qihMT across voxels

#set working data directory
export WD=/Volumes/catherine_team/mvperdue/preschool/multimodal/data

#set MRS data directory
export MRS_DIR=/Volumes/catherine_team/mvperdue/preschool/mrs/data_lag

# for i in $(cat tmp_subs.txt); do
# 	cd ${WD}/${i}
# 	fslmaths ${MRS_DIR}/*${i}*/*mask_WM.nii -bin ${i}_mrs_mask_wm.nii
# 	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask_wm.nii ${i}_qihMT_mrs_mask_wm.nii.gz
# 	fslstats ${i}_qihMT_mrs_mask_wm.nii.gz -M -S >> ${i}_qihMT_LTP-WM_M_SD.txt
# 	cd ${WD}
# done


# apply whole MRS voxel mask to qihMT map and calculate mean qihMT across voxels, write to output txt file

for i in $(cat tmp_subs.txt); do
	cd ${WD}/${i}
	fslmaths ${MRS_DIR}/*${i}*/*mask.nii -bin ${i}_mrs_mask.nii
	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask.nii ${i}_qihMT_mrs_mask.nii.gz
	echo $i $(fslstats ${i}_qihMT_mrs_mask.nii.gz -M -S) >> ../all_qihMT_LTP-M_SD.txt
	cd ${WD}
done


# create tissue mask of excluding CSF, apply to qihMT map, and calculate mean qihMT across voxels, write to output txt file (for exclusion of CSF)

for i in $(cat tmp_subs.txt); do
	cd ${WD}/${i}
	fslmaths ${MRS_DIR}/*${i}*/*mask_CSF.nii -bin ${i}_mrs_mask_csf.nii 
	fslmaths ${i}_mrs_mask.nii -sub ${i}_mrs_mask_csf.nii ${i}_mrs_mask_gm+wm.nii
	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask_gm+wm.nii ${i}_qihMT_mrs_mask_gm+wm.nii.gz
	echo $i $(fslstats ${i}_qihMT_mrs_mask_gm+wm.nii.gz -M -S) >> ../all_qihMT_LTP-M_SD_GM+WM.txt
	cd ${WD}
done
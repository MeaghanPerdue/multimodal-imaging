#!/bin/bash
#calculate mean qihMT values from voxels within MRS mask (white matter only and whole voxel)
# Meaghan Perdue 14 Nov 2022

# apply mask of white matter within MRS voxel to qihMT map and calculate mean qihMT across voxels

#set code directory
export SRC=/Volumes/catherine_team/mvperdue/preschool/multimodal/src

#set working data directory
export WD=/Volumes/catherine_team/mvperdue/preschool/multimodal/data

#set MRS data directory
export MRS_DIR=/Volumes/catherine_team/mvperdue/preschool/mrs/data_lag

# create mask of whole MRS voxel and apply to qihMT map

for i in $(cat ${SRC}/subjlist.txt); do
	cd ${WD}/${i}
	fslmaths ${MRS_DIR}/*${i}*/*mask.nii -bin ${i}_mrs_mask.nii
	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask.nii ${i}_qihMT_mrs_mask.nii.gz
	cd ${WD}
done


# create tissue mask of excluding CSF, apply to qihMT map, and calculate mean qihMT across voxels

for i in $(cat ${SRC}/subjlist.txt); do
	cd ${WD}/${i}
	fslmaths ${MRS_DIR}/*${i}*/*mask_CSF.nii -bin ${i}_mrs_mask_csf.nii 
	fslmaths ${i}_mrs_mask.nii -sub ${i}_mrs_mask_csf.nii ${i}_mrs_mask_gm+wm.nii
	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask_gm+wm.nii ${i}_qihMT_mrs_mask_gm+wm.nii.gz
	cd ${WD}
done

#create mask of white matter within MRS voxel and apply to qihMT map
# for i in $(cat ${SRC}/subjlist.txt); do
# 	cd ${WD}/${i}
# 	fslmaths ${MRS_DIR}/*${i}*/*mask_WM.nii -bin ${i}_mrs_mask_wm.nii
# 	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask_wm.nii ${i}_qihMT_mrs_mask_wm.nii.gz
# 	cd ${WD}
# done

# write qihmt mean and sd values into 1 txt file
# first set up txt file header row
# cd ${WD}
# echo study_code		qihmt_ltp_m 	qihmt_ltp_sd 	qihmt_wm+gm_mean 	qihmt_wm+gm_sd	qihmt_wm_m	qihmt_wm_sd	 >> qihMT_LTP_M-SD_all.txt
	
# write qihMT mean and sd values from each mask into output file
for i in $(cat ${SRC}/subjlist.txt); do
	cd ${WD}/${i}
	echo ${i} 	$(fslstats ${i}_qihMT_mrs_mask.nii.gz -M -S) 	$(fslstats ${i}_qihMT_mrs_mask_gm+wm.nii.gz -M -S) 	$(fslstats ${i}_qihMT_mrs_mask_wm.nii.gz -M -S) >> ${WD}/qihMT_LTP_M-SD_all.txt
	cd ${WD}
done


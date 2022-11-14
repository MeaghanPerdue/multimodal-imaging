#!/bin/bash
#binarize wm mask from Gannet registration
#apply MRS voxel white matter mask to qihMT map 
#calculate mean ihMT value for voxels within the mask
# Meaghan Perdue 14 Nov 2022

for i in $(cat subjlist.txt); do
	cd /Volumes/catherine_team/mvperdue/preschool/multimodal/data/${i}
	fslmaths /Volumes/catherine_team/mvperdue/preschool/mrs/data_lag/*${i}*/PS10085_PS19_001_11288_P67072_mask_WM.nii -bin ${i}_mrs_mask_wm.nii
	fslmaths ${i}_qihMT_reg2T1.nii.gz -mul ${i}_mrs_mask_wm.nii ${i}_qihMT_mrs_mask_wm.nii.gz
	fslstats ${i}_qihMT_mrs_mask_wm.nii.gz -M -S >> ${i}_qihMT_LTP-WM_M_SD.txt
	cd /Volumes/catherine_team/mvperdue/preschool/multimodal/data
done

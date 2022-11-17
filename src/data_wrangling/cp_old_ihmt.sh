#!/bin/bash
#Meaghan Perdue
#17 Nov 2022
#script to copy old ihmt data (from Jess R. processing) to working directory
#copying masked, thresholded qihMT maps

export WD="/Volumes/catherine_team/mvperdue/preschool/multimodal/data"
export IHMT_DIR="/Volumes/catherine_team/mvperdue/preschool/ihMT_KatJess/qihMT original data"

for i in $(cat /Volumes/catherine_team/mvperdue/preschool/multimodal/src/subjlist_old.txt); do
	mkdir $WD/${i}
	cp -Rv $IHMT_DIR/${i}/autoReg/qihMT/qihMTBrain.nii $WD/${i}
	cd $WD/${i} 
	gzip qihMTBrain.nii
	mv qihMTBrain.nii.gz ${i}_qihMTMaskedThresh.nii.gz
	cd $WD
done


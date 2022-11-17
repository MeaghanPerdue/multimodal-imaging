#!/bin/bash
#Meaghan Perdue
#17 Nov 2022
#script to copy old ihmt data (from Jess R. processing) to working directory
#copying masked, thresholded qihMT maps

export WD=/Volumes/catherine_team/mvperdue/preschool/multimodal/data


for i in $(cat subjlist.txt); do
	mkdir $WD/${i}
	cp -Rv /Volumes/catherine_team/mvperdue/preschool/ihMT_KatJess/qihMT original data/${i}/autoReg/qihMT/qihMTBrain.nii $WD/${i}
	cd $WD/${i} 
	mv qihMTBrain.nii ${i}_qihMTMaskedThresh.nii.gz
	cd $WD
done


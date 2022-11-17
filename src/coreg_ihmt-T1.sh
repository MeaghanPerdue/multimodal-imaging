#!/bin/bash
#extract brain from T1w image; coregister processed qihMT map to T1w
#Meaghan Perdue 14 Nov 2022

export WD=/Volumes/catherine_team/mvperdue/preschool/multimodal/data

for i in $(cat subjlist.txt); do
	bet /Volumes/catherine_team/mvperdue/preschool/mrs/data_lag/*${i}*/s${i}*.nii $WD/${i}/${i}_T1_bet.nii.gz
	cd $WD/${i}
	cp -v /Volumes/catherine_team/mvperdue/preschool/ihMT_KatJess/new_data/${i}/${i}_qihMTMaskedThresh.nii.gz .
	flirt -in ${i}_qihMTMaskedThresh.nii.gz -ref ${i}_T1_bet.nii.gz -out ${i}_qihMT_reg2T1.nii.gz
	cd $WD
done

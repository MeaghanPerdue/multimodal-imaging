#!/bin/bash

cd /Volumes/Studies/CL_ACH_PRESCH_01

for i in $(cat /Volumes/catherine_team/mvperdue/preschool/multimodal/src/data_wrangling/sublist.txt)
do
	echo $i $(echo *${i}*/*b0750*) $(echo *${i}*/*b2000*) >> /Volumes/catherine_team/mvperdue/preschool/multimodal/src/data_wrangling/dwi_data_folders.txt
done



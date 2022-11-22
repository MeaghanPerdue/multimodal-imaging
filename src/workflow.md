# Workflow for multimodal registration of MRS, qihMT, and dMRI data
Meaghan Perdue, Nov. 2022

### Software Requirements: FSL

### Prior processing:
MRS voxel has been co-registered with T1w anatomical image and segmented using Gannet/SPM12

qihMT maps have been calculated, masked and thresholded using AFNI/FSL workflow (see ihmt repository: https://github.com/MeaghanPerdue/ihmt )

Create participant folders inside 'data' folder 
Copy qihMT maps (masked and thresholded) to participant folders

## Step 1: Co-register qihMT map with T1w anat
coreg_ihmt-T1.sh

## Step 2: Apply MRS voxel mask to coregistered qihMT map and calculate mean qihMT within mask
mrs_mask_2_ihmt.sh


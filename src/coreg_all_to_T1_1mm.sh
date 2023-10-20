#!/bin/bash
#SBATCH --partition=cpu2023 
#SBATCH --ntasks=1				      
#SBATCH --nodes=1                     # OpenMP requires all tasks running on one node
#SBATCH --cpus-per-task=40               
#SBATCH --time=06:00:00			      # Job should run up to 6 hours

# Normalize and resample T1s to 1mm voxels, run brain extraction
# register qihMT and NODDI maps to 1mm T1s
# this scripts replaces old coreg_ihmt and coreg_NODDI scripts
# Run via ARC
# Meaghan Perdue Oct. 2023
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=40
module load ants/2.5.0
module load fsl/6.0.0-bin
module load afni/1.4.4
module load openmpi/4.1.1-gnu

export WD=/work/lebel_lab/meaghan/multimodal/data
export TEMPLATE=/work/lebel_lab/meaghan/multimodal/oasis_template

cd $WD/${1}
mkdir tmp

# Run bias correction on T1w image
echo "------- Run ANTS N4 bias correction --------"
N4BiasFieldCorrection -v \
    -d 3 \
    -i ${1}_T1_raw.nii \
    -s 2 \
    -c [50x50x50x50,0.0000000001] \
    -o tmp/${1}_T1_N4.nii.gz

# Resample T1 to 1mm isotropic voxels (using afni 3dresample for consistency with Jess' NODDI protocol)
echo "-------- resample to 1mm iso voxels --------"
3dresample -dxyz 1 1 1 -prefix tmp/${1}_T1_N4_1mm.nii.gz -input tmp/${1}_T1_N4.nii.gz 

# Run ANTS brain extraction using OASIS template based on Jess Reynolds' NODDI protocol
echo "-------- run ANTS brain extraction using OASIS templates --------"
antsBrainExtraction.sh -v \
    -d 3 -a tmp/${1}_T1_N4_1mm.nii.gz \
    -e $TEMPLATE/T_template0.nii.gz \
    -m $TEMPLATE/T_template0_BrainCerebellumProbabilityMask.nii.gz \
    -f $TEMPLATE/T_template0_BrainCerebellumRegistrationMask.nii.gz \
    -o ${1}_T1_N4_1mm_

# Register qihMT map to ANTS BET 1mm T1 
echo "-------- Register qihMT map to T1 --------"
antsRegistrationSyN.sh -v \
    -f ${1}_T1_N4_1mm_BrainExtractionBrain.nii.gz \
    -m ${1}_qihMTMaskedThresh.nii.gz \
    -x ${1}_T1_N4_1mm_BrainExtractionMask.nii.gz \
    -t s \
    -o ${1}_qihMT_reg2antsT1_N4_1mm_

# resample mrs voxel to 1mm voxel size and binarize
echo "------- resample and binarize MRS voxel --------" 
flirt -in ${1}_mrs_mask.nii.gz \
    -ref ${1}_T1_N4_1mm_BrainExtractionBrain.nii.gz \
    -applyisoxfm 1.0 \
    -nosearch \
    -out ${1}_mrs_mask_1mm.nii.gz
fslmaths ${1}_mrs_mask_1mm.nii.gz -bin ${1}_mrs_mask_1mm.nii.gz

# ANTS registration NODDI to T1 using 3-stage approach: rigid, affine, deformable syn 
# this produced much better image alignment vs. the 2-stage rigid, affine method
# first, run registration using ODI map (better contrast than NDI)
# echo "------- Register ODI to T1 --------"
# antsRegistrationSyN.sh \
#     -f ${1}_T1_N4_1mm_BrainExtractionBrain.nii.gz \
#     -m ${1}_fitted_odi.nii \
#     -x ${1}_T1_N4_1mm_BrainExtractionMask.nii.gz \
#     -t s \
#     -o ${1}_ODI_reg2antsT1_N4_1mm_

# # Apply transforms from ODI->T1 registration affine stage to NDI map, rigid & affine steps 
# echo "------- Register NDI to T1: rigid, affine --------"
# antsApplyTransforms \
#     -i ${1}_fitted_ficvf.nii \
#     -t ${1}_ODI_reg2antsT1_N4_1mm_0GenericAffine.mat \
#     -r ${1}_T1_N4_1mm_BrainExtractionBrain.nii.gz \
#     -o tmp/${1}_NDI_reg2antsT1_N4_1mm_AffineWarped.nii.gz

# # Run deformable syn registration step on NDI to complete registration to T1 space
# echo "------- Register NDI to T1: SynB --------"
# antsRegistrationSyN.sh \
#     -f ${1}_T1_N4_1mm_BrainExtractionBrain.nii.gz \
#     -m tmp/${1}_NDI_reg2antsT1_N4_1mm_AffineWarped.nii.gz \
#     -x ${1}_T1_N4_1mm_BrainExtractionMask.nii.gz \
#     -t so \
#     -o ${1}_NDI_reg2antsT1_N4_1mm_


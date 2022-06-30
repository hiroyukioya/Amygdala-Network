###################################################################
###########                                           ##############
###########          Build BIDS file structures       ##############
###########                                           ##############
####################################################################
# Update AFNI binaries:
@update.afni.binaries -defaults

###############################################################
#####   PREPARATION OF SCANS 
###############################################################

PATH=$PATH:~/mricrogl_lx

# DIRECTORIES ================================================
# Define directries ...
pid=515
dcmdir=~/es-fMRI/pt$pid/niidata
basedir=~/es-fMRI/BIDS/sub-$pid

##############################################################
# Make directries ...
mkdir $dcmdir
mkdir $basedir
cd $basedir
mkdir $basedir/ses-01
mkdir $basedir/ses-02
preopdir=$basedir/ses-01
postopdir=$basedir/ses-02

mkdir $preopdir/anat
mkdir $preopdir/func
mkdir $preopdir/fmap

mkdir $postopdir/anat
mkdir $postopdir/func
mkdir $postopdir/fmap

mkdir $dcmdir/pre
mkdir $dcmdir/post

###############################################################
# DICOM Conversion ============================================
###############################################################
# [Pre-OP]: Convert DICOM to NII (Pre-implantation scans)
dcm2niix -ba y -s n -f '%p_%s' -o $dcmdir/pre/  ~/es-fMRI/pt$pid/20171030

# [POST-OP]: Convert DICOM to NII (ES-fMRI ; post-implantation scans)
dcm2niix -ba y -s y -f '%p_%s' -o $dcmdir/post/  ~/es-fMRI/pt$pid/412


###############################################################
# FIELDMAPs ===================================================
###############################################################
#   "EchoTime1": 0.00489,
#	"EchoTime2": 0.00735,
#    Make sure  "IntendedFor" field is there in JASON file

# Pre-implantation scan fieldmap for resting data------------------------
mag=11
phase=4
cp $dcmdir/pre/Field_Map_$mag.nii $preopdir/fmap/sub-$pid'_ses-01_run-01_magnitude1.nii'
# cp $dcmdir/pre/Field_Map_$mag.nii $preopdir/fmap/sub-$pid'_ses-01_run-01_magnitude2.nii'
cp $dcmdir/pre/Field_Map_$phase.nii $preopdir/fmap/sub-$pid'_ses-01__run-01_phasediff.nii'
cp $dcmdir/pre/Field_Map_$phase.json $preopdir/fmap/sub-$pid'_ses-01_run-01_phasediff.json'

# if Magnitude and Phase are combined, separate them here ----
mag=6
3dTsplit4D -prefix $preopdir/fmap/sub-$pid'_ses-01_run-01.nii' $dcmdir/pre/Field_Map_$mag.nii 
cp $preopdir/fmap/sub-$pid'_ses-01_run-01.0.nii' $preopdir/fmap/sub-$pid'_ses-01_run-01_phasediff.nii'
cp $preopdir/fmap/sub-$pid'_ses-01_run-01.1.nii' $preopdir/fmap/sub-$pid'_ses-01_run-01_magnitude1.nii'
cp $preopdir/fmap/sub-$pid'_ses-01_run-01.1.nii' $preopdir/fmap/sub-$pid'_ses-01_run-01_magnitude2.nii'
rm $preopdir/fmap/sub-$pid'_ses-01_run-01.'*
cp $dcmdir/pre/Field_Map_$mag.json $preopdir/fmap/sub-$pid'_ses-01_run-01_phasediff.json'

# POST-op. fieldmap-----------------------------
mag=3
phase=4
cp $dcmdir/post/Field_Map_$mag.nii $postopdir/fmap/sub-$pid'_ses-02_run-01_magnitude1.nii'
cp $dcmdir/post/Field_Map_$mag.nii $postopdir/fmap/sub-$pid'_ses-02_run-01_magnitude2.nii'
cp $dcmdir/post/Field_Map_$phase.nii $postopdir/fmap/sub-$pid'_ses-02_run-01_phasediff.nii'
cp $dcmdir/post/Field_Map_$phase.json $postopdir/fmap/sub-$pid'_ses-02_run-01_phasediff.json'

# Correct wrong FieldMap acquisition slice order.  
# Flip S-I direction
cd $postopdir/fmap
3dLRflip -IS -prefix sub-'$pid'_ses-01_run-01_magnitude1 ./sub-$pid'_ses-01_run-01_magnitude1.nii'
3dLRflip -IS -prefix sub-'$pid'_ses-01_run-01_magnitude2 ./sub-$pid'_ses-01_run-01_magnitude2.nii'
3dLRflip -IS -prefix sub-'$pid'_ses-01_run-01_phasediff ./sub-$pid'_ses-01_run-01_phasediff.nii'

# rm ./sub-$pid'_ses-02_run-01_phasediff.nii'
# rm ./sub-$pid'_ses-02_run-01_magnitude1.nii'
# rm ./sub-$pid'_ses-02_run-01_magnitude2.nii'

3dAFNItoNIFTI sub-Aaron_ses-01_run-01_magnitude1+orig
3dAFNItoNIFTI sub-Aaron_ses-01_run-01_magnitude2+orig
3dAFNItoNIFTI sub-Aaron_ses-01_run-01_phasediff+orig
rm sub-Aaron_ses-01_run-01_magnitude1+orig* sub-Aaron_ses-01_run-01_magnitude2+orig* sub-Aaron_ses-01_run-01_phasediff+orig*

############################################################
# 1: Make sure to update "participants.tsv" file
# 2: Make sure to create sub-$pid_task-es_bold.json file in ./mybids/sub-$pid folder ....
# 3: "IntendedFor" field is there in JASON file in fmap needs to be added.

# ----------- Example (Siemens)----------- #
 	 "EchoTime1": 0.00489,
 	 "EchoTime2": 0.00735,
     "IntendedFor":["ses-02/func/sub-405_ses-02_task-es_run-1_bold.nii",
 	 "ses-02/func/sub-405_ses-02_task-es_run-2_bold.nii",
 	 "ses-02/func/sub-405_ses-02_task-es_run-3_bold.nii",
 	 "ses-02/func/sub-405_ses-02_task-es_run-4_bold.nii",
 	 "ses-02/func/sub-405_ses-02_task-es_run-5_bold.nii",
 	 "ses-02/func/sub-405_ses-02_task-es_run-6_bold.nii"],	
 	 
# Another example [GE Discovery 750w]
	"EchoTime1": 0.004608,
	"EchoTime2": 0.006912,
	"IntendedFor": ["ses-01/func/sub-400_ses-01_task-rest_run-1_bold.nii",
	"ses-01/func/sub-400_ses-01_task-rest_run-2_bold.nii",
	"ses-01/func/sub-400_ses-01_task-rest_run-3_bold.nii",
	"ses-01/func/sub-400_ses-01_task-rest_run-4_bold.nii",
	"ses-01/func/sub-400_ses-01_task-rest_run-5_bold.nii"],

################################################################# 
# ANATOMICAL IMAGES =============================================
################################################################# 

# Deface .....
cd $dcmdir/pre
# Pre-op T1 structural .....
pydeface --force --cost normmi --outfile ./sub-$pid'_T1w_defaced.nii' ./'Preop-T1w-1.nii'
cp ./sub-$pid'_T1w_defaced.nii' $basedir/ses-01/anat/sub-$pid'_ses-01_T1w.nii'
cp ./'Preop-T1w-1.json' $basedir/ses-01/anat/sub-$pid'_ses-01_T1w.json'

# Pre-op T2 structural .....
cd $dcmdir/pre
pydeface --force --cost normmi --outfile ./sub-$pid'_T2w_defaced.nii' ./'PU_CUBE_T2_Sagittal_1000.nii'
cp ./sub-$pid'_T2w_defaced.nii' $basedir/ses-01/anat/sub-$pid'_ses-01_T2w.nii'
cp ./'PU_CUBE_T2_Sagittal_1000.json' $basedir/ses-01/anat/sub-$pid'_ses-01_T2w.json'

# Post-op T1 structural .....
cd $dcmdir/post
pydeface --force --cost normmi --outfile ./sub-$pid'_T1w_defaced.nii' 'MPRAGE_TI=1100_2.nii'
cp ./sub-$pid'_T1w_defaced.nii' $basedir/ses-02/anat/sub-$pid'_ses-02_T1w.nii'
cp './MPRAGE_TI=1100_2.json' $basedir/ses-02/anat/sub-$pid'_ses-02_T1w.json'


################################################################
# FUNCTIONAL ===================================================
################################################################

# Copy functinal nii- and json- files ..
# Before this, create timing files in pt---/001... folder
cd $basedir
fdata=(4 6 7 9 10 12)  # Series number for functional images
ix=-1
for ptid  in "${fdata[@]}" 
do
    ix=$((ix+1))       # Counter 
    eid=${fdata[$ix]}  # Exp-session-ID
    fid=$((ix+1))      # Run number 
    echo "   "
    echo "exp ID =" $fid "  series ID = " $eid "   run = $pid-00$fid "
    if test "$pid" -le "294"
    then
        cp $dcmdir"/post/ES_FMRI_"$eid.nii $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_bold.nii'
        cp $dcmdir"/post/ES_FMRI_"$eid.json $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_bold.json'
    elif test "$pid" -eq "322"
    then
        cp $dcmdir"/post/ES-FMRI-NEW_"$eid.nii $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_bold.nii'
        cp $dcmdir"/post/ES-FMRI-NEW_"$eid.json $basedir/ses-02/func/sub-$pid'_ses_02_task-es_run-'$fid'_bold.json'
    else
        cp $dcmdir"/post/ES-FMRI_"$eid.nii $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_bold.nii'
        cp $dcmdir"/post/ES-FMRI_"$eid.json $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_bold.json'
    fi
    echo "   "
done


# ADD "TASKNAME" field IN JASON as below:
cp ~/es-fMRI/BIDS/sub-403/ses-02/func/sub-403_ses-02_task-es_bold.json $basedir/ses-02/func/sub-$pid'_ses-02_task-es_bold.json'


#
#	"TaskName": "es",
#}

###################################################################
# Create Timing Information file ===================================
###################################################################

# Create first run's events file and copy ....
cp ~/es-fMRI/BIDS/sub-399/ses-02/func/sub-399_ses-02_task-es_run-1_events.tsv ~/es-fMRI/BIDS/sub-$pid/ses-02/func/sub-"$pid"_ses-02_task-es_run-1_events.tsv 

# Copy the run1's event file unles any changes.
ix=-1
for ptid  in "${fdata[@]}" 
do
    ix=$((ix+1))       # Counter 
    eid=${fdata[$ix]}  # Exp-session-ID
    fid=$((ix+1))      # Run number 
    echo "   "
    echo "exp ID =" $fid "  series ID = " $eid "   run = $pid-00$fid "
    # Timing information file ....
    cp $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-1_events.tsv' $basedir/ses-02/func/sub-$pid'_ses-02_task-es_run-'$fid'_events.tsv'
    echo "   "
done


############################################################
#######################  FMRIPREP  #########################

# Install fmriprep-docker ...
sudo pip install --user --upgrade fmriprep-docker

# dir ...
expdir=/home/hiroyuki/es-fMRI/BIDS/sub-$pid

# RUN fmriprep-docker on a subject's data ......
# Processed data will be in ~/es-fMRI/Preproc folder ....
# Note, you need sudo privilege.

# BIDS validator ...........
http://bids-standard.github.io/bids-validator/

# Run the preprocessing .......
sudo fmriprep-docker \
~/es-fMRI/BIDS \
~/es-fMRI/fMRI_PREP_results_temp participant \
--participant_label 384 \
--task-id "es" \
--output-space T1w MNI152NLin2009cAsym fsaverage \
--write-graph \
--work-dir ~/es-fMRI/fMRI_PREP_results_temp/PreprocTemp \
--fs-license-file /usr/local/FS6.0/license.txt \
--fs-no-reconall \
--bold2t1w-dof 9


#########################################################
# Copy the necessary files into analysis folder 
mkdir ~/es-fMRI/AMYG
basedir=~/es-fMRI/AMYG
mkdir ~/es-fMRI/AMYG/$pid

ptlist=(294 294 302 303 307 307 314 316 316 322 \
322 330 331 331 334 334 334 334 335 352 \
352 352 369 369 369 369 369 372 372 372 \
384 384 384 384 394 394 395 395 395 399 \
399 400 403 405 405 407 407 407 412)
runlist=(1 2 2 1 3 7 4 3 4 2 \
4 7 5 6 5 6 7 8 3 1 \
2 3 4 5 6 7 8 2 3 4 \
1 2 3 4 3 4 1 2 4 3 \
8 3 3 3 4 1 2 3 1)

ses=02
task=es
pind=-1

for ((k=30;k<=33;k++))
do 
    echo '---------------------'  
    echo $k
    run=${runlist[$k]}
    pid=${ptlist[$k]}
    echo '          '
    echo '          '
    echo      Running $pid '-' $run 
    echo '          '
    echo '          '
    echo '          '
    mkdir ~/es-fMRI/AMYG/$pid
    mkdir ~/es-fMRI/AMYG/$pid/$run
    adir=~/es-fMRI/AMYG/$pid/$run
    cd $adir
    
    # Copy MNI space BOLD 
    cd ~/es-fMRI/fMRI_PREP_results/fmriprep/sub-$pid/ses-$ses/func/
    cp -T sub-$pid'_ses-'$ses'_task-'$task'_run-'$run'_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz' $adir/bold.nii.gz

    # COPY MNI space ANAT data 
    cd ~/es-fMRI/fMRI_PREP_results/fmriprep/sub-$pid/anat/
    cp -T sub-$pid'_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz' $adir/T1w_MNI_anat.nii.gz

    # COPY cofounds regressors  
    rm $adir/confounds*
    cd ~/es-fMRI/fMRI_PREP_results/fmriprep/sub-$pid/ses-$ses/func/
    cp -T sub-$pid'_ses-'$ses'_task-'$task'_run-'$run'_desc-confounds_regressors.tsv' $adir/confounds.tsv

    # Copy event file  
    cd ~/BIDS/sub-$pid/ses-$ses/func/
    cp -T sub-$pid'_ses-'$ses'_task-'$task'_run-'$run'_events.tsv' $adir/events.tsv

    # Copy anatomical Mask 
    cd ~/es-fMRI/fMRI_PREP_results/fmriprep/sub-$pid/anat/
    cp -T sub-$pid'_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz' $adir/T1w_anat_mask.nii.gz

    # Copy functional Mask 
    cd ~/es-fMRI/fMRI_PREP_results/fmriprep/sub-$pid/ses-$ses/func/
    cp -T sub-$pid'_ses-'$ses'_task-'$task'_run-'$run'_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz' $adir/bold-mask.nii.gz
done





#------------------------------------------------          # 
#      Process upto Smoothing                              #
#------------------------------------------------          #
# Run ~/es-fMRI/AMYG/mkConfounds.m before this block       #
#------------------------------------------------          #
pind=-1

for ((k=30;k<=33;k++))
do 
    echo '---------------------'  
    run=${runlist[$k]}
    pid=${ptlist[$k]}
    echo '          '
    echo '          '
    echo      Running $pid '-' $run 
    adir=~/es-fMRI/AMYG/$pid/$run
    cd $adir
    echo '          '
    echo '          '
    echo '          ' 
        
    # Calculate meanEPI from unsmoothed data ......
    cd $adir
    rm meanEPI*
    3dTstat -mean -prefix meanEPI $adir/bold.nii.gz

    # Run ~/es-fMRI/AMYG/mkConfounds.m .......
    # Plot confounds TS ........
    cd $adir
    1dplot -png  FD fd.1D
    1dplot -png  WM wm.1D
    1dplot -png  GS gs.1D
    1dplot -png  DVARS dvars.1D
    1dplot -png  ACompCor -norm2 Acompcor.1D
    1dplot -png MotionParams -norm2 motion.1D
    1dplot -png MotionDerivParams -norm2 motion_deriv.1D

    # Create censor file ........
    rm f-TR_*
    1d_tool.py -infile fd.1D \
    -show_censor_count \
    -moderate_mask 0 0.9 \
    -censor_first_trs 5 \
    -censor_prev_TR \
    -write f-TR_censor.1D

    # Scaling .........
    cd $adir
    rm meanBOLD* rm scaled_*
    3dTstat -mean -prefix meanBOLD bold.nii.gz
    3dcalc -a bold.nii.gz -b meanBOLD+tlrc -c bold-mask.nii.gz \
    -expr 'c*min(200,100*a/b)' \
    -prefix scaled_bold

    # Smoothing ..........
    cd $adir
    rm filt-HSBM*
    3dmerge -1filter_blur 6 -doall -1fmask bold-mask.nii.gz -prefix filt-HSBM6mm scaled_bold+tlrc
done


##########################################
mkdir ~/es-fMRI/AMYG
basedir=~/es-fMRI/AMYG
mkdir ~/es-fMRI/AMYG/$pid
cd $adir

ses=02
task=es

pind=-1
k=-1
for ptid  in "${ptlist[@]}" 
do 
    echo '---------------------'  
    k=$((k+1))
    run=${runlist[$k]}
    pid=${ptlist[$k]}
    echo '          '
    echo '          '
    echo      Running $pid '-' $run 
    echo '          '
    echo '          '
    echo '          '
    adir=~/es-fMRI/AMYG/$pid/$run
    cd $adir
    
    # Copy MNI spae BOLD 
    cd ~/es-fMRI/BIDS/sub-$pid/ses-$ses/func/
    cp -T sub-$pid'_ses-'$ses'_task-'$task'_run-'$run'_events.tsv' $adir/Stim.1D

done
###########################################
###########################################
###########################################
###############    GLM     ################
###########################################
###########################################
pind=-1
k=-1

#for ptid  in "${ptlist[@]}" 
for ((k=30;k<=33;k++))
do 
    echo '---------------------'  
    #k=$((k+1))
    run=${runlist[$k]}
    pt=${ptlist[$k]}
    echo '          '
    echo '          '
    echo '          '
    echo      Running $pt '-' $run 
    echo '          '
    echo '          '
    echo '          '
    basedir=~/es-fMRI/AMYG/$pt/$run
    cd $basedir
    
    # Make mask ............
    rm AutoMASK+tlrc*
    3dAutomask -nbhrs 13 -peels 0 -erode 0 -prefix AutoMASK meanEPI+tlrc
    
    # RUN GLM --------------------------------
    rm FitTS6mm-Tcomp* CLSig6mm* "FMRIPREP_MNI_"$pt'_'$run'_BLOCK_6mm_AcompcorMD'* fb$pt'_'* Xmat-6mm-acompcor.X1D*
    3dDeconvolve -input filt-HSBM6mm+tlrc -num_stimts 19 \
    -stim_times 1 Stim.1D 'BLOCK5(0.1,1)' \
    -stim_label 1 ES \
    -stim_file 2 Acompcor.1D[0] -stim_base 2 -stim_label 2 compcor-0  \
    -stim_file 3 Acompcor.1D[1] -stim_base 3 -stim_label 3 compcor-1  \
    -stim_file 4 Acompcor.1D[2] -stim_base 4 -stim_label 4 compcor-2  \
    -stim_file 5 Acompcor.1D[3] -stim_base 5 -stim_label 5 compcor-3  \
    -stim_file 6 Acompcor.1D[4] -stim_base 6 -stim_label 6 compcor-4  \
    -stim_file 7 Acompcor.1D[5] -stim_base 7 -stim_label 7 compcor-5  \
    -stim_file 8 motion.1D[0] -stim_base 8 -stim_label 8 m-0  \
    -stim_file 9 motion.1D[1] -stim_base 9 -stim_label 9 m-1  \
    -stim_file 10 motion.1D[2] -stim_base 10 -stim_label 10 m-2  \
    -stim_file 11 motion.1D[3] -stim_base 11 -stim_label 11 m-3  \
    -stim_file 12 motion.1D[4] -stim_base 12 -stim_label 12 m-4  \
    -stim_file 13 motion.1D[5] -stim_base 13 -stim_label 13 m-5 \
    -stim_file 14 motion_deriv.1D[0] -stim_base 14 -stim_label 14 md-0  \
    -stim_file 15 motion_deriv.1D[1] -stim_base 15 -stim_label 15 md-1  \
    -stim_file 16 motion_deriv.1D[2] -stim_base 16 -stim_label 16 md-2  \
    -stim_file 17 motion_deriv.1D[3] -stim_base 17 -stim_label 17 md-3  \
    -stim_file 18 motion_deriv.1D[4] -stim_base 18 -stim_label 18 md-4  \
    -stim_file 19 motion_deriv.1D[5] -stim_base 19 -stim_label 19 md-5 \
    -errts 'CLSig6mm' \
    -fout \
    -tout \
    -nobout \
    -x1D Xmat-6mm-acompcor.X1D \
    -fitts FitTS6mm-Tcomp \
    -bucket "FMRIPREP_MNI_"$pt'_'$run"_BLOCK_6mm_AcompcorMD" \
    -polort 5 \
    -xjpeg DesignMatrix-Tcomp \
    -mask AutoMASK+tlrc  \
    -censor f-TR_censor.1D 
done

###########################################
###############    GLM 2    ################
pind=-1
k=-1

for ptid  in "${ptlist[@]}" 
do 
    echo '---------------------'  
    k=$((k+1))
    run=${runlist[$k]}
    pt=${ptlist[$k]}
    echo '          '
    echo '          '
    echo '          '
    echo      Running $pt '-' $run 
    echo '          '
    echo '          '
    echo '          '
    basedir=~/es-fMRI/AMYG/$pt/$run
    cd $basedir
    
    # Make mask ............
    rm AutoMASK+tlrc*
    3dAutomask -nbhrs 13 -peels 0 -erode 0 -prefix AutoMASK T1w_MNI_anat+tlrc
    
    # RUN GLM --------------------------------
    rm FitTS6mm-Tcomp* CLSig6mm* "FMRIPREP_MNI_"$pt'_'$run'_BLOCK_6mm_AcompcorMO'* fb$pt'_'* Xmat-6mm-acompcorMO.X1D*
    3dDeconvolve -input filt-HSBM6mm+tlrc -num_stimts 13 \
    -stim_times 1 Stim.1D 'BLOCK5(0.1,1)' \
    -stim_label 1 ES \
    -stim_file 2 Acompcor.1D[0] -stim_base 2 -stim_label 2 compcor-0  \
    -stim_file 3 Acompcor.1D[1] -stim_base 3 -stim_label 3 compcor-1  \
    -stim_file 4 Acompcor.1D[2] -stim_base 4 -stim_label 4 compcor-2  \
    -stim_file 5 Acompcor.1D[3] -stim_base 5 -stim_label 5 compcor-3  \
    -stim_file 6 Acompcor.1D[4] -stim_base 6 -stim_label 6 compcor-4  \
    -stim_file 7 Acompcor.1D[5] -stim_base 7 -stim_label 7 compcor-5  \
    -stim_file 8 motion.1D[0] -stim_base 8 -stim_label 8 m-0  \
    -stim_file 9 motion.1D[1] -stim_base 9 -stim_label 9 m-1  \
    -stim_file 10 motion.1D[2] -stim_base 10 -stim_label 10 m-2  \
    -stim_file 11 motion.1D[3] -stim_base 11 -stim_label 11 m-3  \
    -stim_file 12 motion.1D[4] -stim_base 12 -stim_label 12 m-4  \
    -stim_file 13 motion.1D[5] -stim_base 13 -stim_label 13 m-5 \
    -errts 'CLSig6mm' \
    -fout \
    -tout \
    -nobout \
    -x1D Xmat-6mm-acompcorMO.X1D \
    -fitts FitTS6mm-Tcomp \
    -bucket "FMRIPREP_MNI_"$pt'_'$run"_BLOCK_6mm_AcompcorMO" \
    -polort 5 \
    -xjpeg DesignMatrix-AcompMO \
    -mask AutoMASK+tlrc  \
    -censor f-TR_censor.1D 
done

#########################################################
### GLM without MASK ###################################
pind=-1
k=-1

for ptid  in "${ptlist[@]}" 
do 
    echo '_______________________________'  
    k=$((k+1))
    run=${runlist[$k]}
    pt=${ptlist[$k]}
    echo '          '
    echo '          '
    echo '          '
    echo      Running $pt '-' $run 
    echo '          '
    echo '          '
    echo '          '
    basedir=~/es-fMRI/AMYG/$pt/$run
    cd $basedir
    
    # RUN GLM --------------------------------
    rm FitTS6mm-Tcomp* CLSig6mm* "FMRIPREP_MNI_"$pt'_'$run'_BLOCK_6mm_AcompcorMO'* fb$pt'_'* Xmat-6mm-acompcorMO.X1D*
    3dDeconvolve -input filt-HSBM6mm+tlrc -num_stimts 13 \
    -stim_times 1 Stim.1D 'BLOCK5(0.1,1)' -stim_label 1 ES \
    -stim_file 2 Acompcor.1D[0] -stim_base 2 -stim_label 2 compcor-0  \
    -stim_file 3 Acompcor.1D[1] -stim_base 3 -stim_label 3 compcor-1  \
    -stim_file 4 Acompcor.1D[2] -stim_base 4 -stim_label 4 compcor-2  \
    -stim_file 5 Acompcor.1D[3] -stim_base 5 -stim_label 5 compcor-3  \
    -stim_file 6 Acompcor.1D[4] -stim_base 6 -stim_label 6 compcor-4  \
    -stim_file 7 Acompcor.1D[5] -stim_base 7 -stim_label 7 compcor-5  \
    -stim_file 8 motion.1D[0] -stim_base 8 -stim_label 8 m-0  \
    -stim_file 9 motion.1D[1] -stim_base 9 -stim_label 9 m-1  \
    -stim_file 10 motion.1D[2] -stim_base 10 -stim_label 10 m-2  \
    -stim_file 11 motion.1D[3] -stim_base 11 -stim_label 11 m-3  \
    -stim_file 12 motion.1D[4] -stim_base 12 -stim_label 12 m-4  \
    -stim_file 13 motion.1D[5] -stim_base 13 -stim_label 13 m-5 \
    -errts 'CLSig6mm' \
    -fout \
    -tout \
    -nobout \
    -x1D Xmat-6mm-acompcorMOWO.X1D \
    -fitts FitTS6mm-Tcomp \
    -bucket "FMRIPREP_MNI_"$pt'_'$run"_BLOCK_6mm_AcompcorMOWO" \
    -polort 5 \
    -xjpeg DesignMatrix-AcompMO \
    -censor f-TR_censor.1D 
done

###########################################################
###########################################################
###############        REML FITTING       #################
###########################################################
###########################################################

#1 RUN_REML_FITTINGs ........................
pind=-1
k=-1
for ((k=30;k<=33;k++))
do
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"  
  run=${runlist[$k]}
  pt=${ptlist[$k]}
  echo "    "
  echo "    " $((k+1)) ":" $pt "-" $run
  echo "    "
  basedir=~/es-fMRI/AMYG/$pt/$run
  cd $basedir
  # REML fitting ..............
  rm CLSig6mmWO_REML* FitTS6mmWO_REML* FMRIPREP_MNI_"$pt"_"$run"_BLOCK_6mm_AcompcorMOWO_REML*
  
  3dREMLfit -matrix Xmat-6mm-acompcor.X1D \
  -input filt-HSBM6mm+tlrc \
  -mask AutoMASK+tlrc \
  -fout -tout \
  -Rbuck FMRIPREP_MNI_"$pt"_"$run"_BLOCK_6mm_AcompcorMD_REML \
  -Rvar FMRIPREP_MNI_"$pt"_"$run"_BLOCK_6mm_AcompcorMOMD_REMLvar \
  -Rfitts FitTS6mm-AcompMD_REML \
  -Rerrts CLSig6mmMD_REML \
  -verb $*
done


#2 Load and make the data in same dimension  ................
cd /home/hiroyuki/es-fMRI/AMYG/amy 
for ((k=30;k<=33;k++))
do
  echo "---------------------"  
  run=${runlist[$k]}
  pt=${ptlist[$k]}
  echo "    " $((k+1)) ":" $pt "-" $run
  echo "    "
  rm "R"$((k+1))+*
  echo "  RESAMPLING  " $((k+1)) ":" $pt "-" $run
    3dresample -master ~/es-fMRI/AMYG/307/3/FMRIPREP_MNI_307_3_BLOCK_6mm_TcompcorFD+tlrc \
    -prefix "R"$((k+1)) \
    -input ~/es-fMRI/AMYG/$pt/$run/FMRIPREP_MNI_"$pt"_"$run"_BLOCK_6mm_AcompcorMD_REML+tlrc
done


#3; Make Brain only image ............
3dcalc -a mni_icbm152_t1_tal_nlin_asym_09c.nii \
-b mni_icbm152_t1_tal_nlin_asym_09c_mask.nii \
-expr '(a*b)' -prefix mni_icbm152_brain

#4; Create brain mask ..............
rm AmaskD*
3dresample -master ~/es-fMRI/AMYG/307/3/FMRIPREP_MNI_307_3_BLOCK_6mm_TcompcorFD+tlrc -prefix AmaskD \
-input mni_icbm152_t1_tal_nlin_asym_09c_mask.nii

###########################################################
###########################################################
######     Group Analysis  ################################
###########################################################
###########################################################

#5 RUNNING MEMA group analysis .............
rm REML-GroupResults_MNI_MEMA_amygAll*
3dMEMA \
-jobs 4 \
-set  ES \
ac1 R1+tlrc'[1]' R1+tlrc'[2]' \
ac2 R2+tlrc'[1]' R2+tlrc'[2]' \
ac3 R4+tlrc'[1]' R4+tlrc'[2]' \
ac4 R5+tlrc'[1]' R5+tlrc'[2]' \
ac5 R6+tlrc'[1]' R6+tlrc'[2]' \
ac7 R11+tlrc'[1]' R11+tlrc'[2]' \
ac8 R12+tlrc'[1]' R12+tlrc'[2]' \
ac9 R13+tlrc'[1]' R13+tlrc'[2]' \
ac10 R14+tlrc'[1]' R14+tlrc'[2]' \
ac11 R15+tlrc'[1]' R15+tlrc'[2]' \
ac13 R17+tlrc'[1]' R17+tlrc'[2]' \
ac14 R18+tlrc'[1]' R18+tlrc'[2]' \
ac15 R19+tlrc'[1]' R19+tlrc'[2]' \
ac16 R20+tlrc'[1]' R20+tlrc'[2]' \
ac17 R21+tlrc'[1]' R21+tlrc'[2]' \
ac18 R22+tlrc'[1]' R22+tlrc'[2]' \
ac19 R23+tlrc'[1]' R23+tlrc'[2]' \
ac20 R24+tlrc'[1]' R24+tlrc'[2]' \
ac21 R25+tlrc'[1]' R25+tlrc'[2]' \
ac23 R27+tlrc'[1]' R27+tlrc'[2]' \
ac24 R28+tlrc'[1]' R28+tlrc'[2]' \
ac25 R29+tlrc'[1]' R29+tlrc'[2]' \
ac26 R30+tlrc'[1]' R30+tlrc'[2]' \
ac27 R31+tlrc'[1]' R31+tlrc'[2]' \
ac28 R32+tlrc'[1]' R32+tlrc'[2]' \
ac29 R33+tlrc'[1]' R33+tlrc'[2]' \
ac30 R34+tlrc'[1]' R34+tlrc'[2]' \
ac31 R35+tlrc'[1]' R35+tlrc'[2]' \
ac32 R36+tlrc'[1]' R36+tlrc'[2]' \
ac33 R37+tlrc'[1]' R37+tlrc'[2]' \
ac34 R38+tlrc'[1]' R38+tlrc'[2]' \
ac35 R39+tlrc'[1]' R39+tlrc'[2]' \
ac36 R40+tlrc'[1]' R40+tlrc'[2]' \
ac37 R42+tlrc'[1]' R42+tlrc'[2]' \
ac38 R43+tlrc'[1]' R43+tlrc'[2]' \
ac39 R44+tlrc'[1]' R44+tlrc'[2]' \
ac40 R45+tlrc'[1]' R45+tlrc'[2]' \
ac41 R46+tlrc'[1]' R46+tlrc'[2]' \
-max_zeros 0.75   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-mask  Amask2+tlrc \
-HKtest \
-prefix REML-GroupResults_MNI_MEMA_amygAll


## Contrast at 24 mm-------------------

rm REML-GroupResults_MNI_MEMA_amygCont24*
3dMEMA \
-groups Lateral Medial \
-set   Lateral \
ac1 R1+tlrc'[1]' R1+tlrc'[2]' \
ac2 R6+tlrc'[1]' R6+tlrc'[2]' \
ac3 R11+tlrc'[1]' R11+tlrc'[2]' \
ac4 R12+tlrc'[1]' R12+tlrc'[2]' \
ac5 R14+tlrc'[1]' R14+tlrc'[2]' \
ac6 R17+tlrc'[1]' R17+tlrc'[2]' \
ac7 R18+tlrc'[1]' R18+tlrc'[2]' \
ac8 R19+tlrc'[1]' R19+tlrc'[2]' \
ac9 R21+tlrc'[1]' R21+tlrc'[2]' \
ac10 R22+tlrc'[1]' R22+tlrc'[2]' \
ac11 R25+tlrc'[1]' R25+tlrc'[2]' \
ac12 R28+tlrc'[1]' R28+tlrc'[2]' \
ac13 R30+tlrc'[1]' R30+tlrc'[2]' \
ac14 R33+tlrc'[1]' R33+tlrc'[2]' \
ac15 R35+tlrc'[1]' R35+tlrc'[2]' \
ac16 R37+tlrc'[1]' R37+tlrc'[2]' \
ac17 R38+tlrc'[1]' R38+tlrc'[2]' \
ac18 R39+tlrc'[1]' R39+tlrc'[2]' \
ac19 R2+tlrc'[1]' R2+tlrc'[2]' \
ac20 R45+tlrc'[1]' R45+tlrc'[2]' \
ac21 R46+tlrc'[1]' R46+tlrc'[2]' \
-set Medial \
ac22 R4+tlrc'[1]' R4+tlrc'[2]' \
ac23 R5+tlrc'[1]' R5+tlrc'[2]' \
ac25 R13+tlrc'[1]' R13+tlrc'[2]' \
ac26 R15+tlrc'[1]' R15+tlrc'[2]' \
ac27 R16+tlrc'[1]' R16+tlrc'[2]' \
ac28 R20+tlrc'[1]' R20+tlrc'[2]' \
ac29 R23+tlrc'[1]' R23+tlrc'[2]' \
ac30 R24+tlrc'[1]' R24+tlrc'[2]' \
ac32 R27+tlrc'[1]' R27+tlrc'[2]' \
ac33 R29+tlrc'[1]' R29+tlrc'[2]' \
ac34 R31+tlrc'[1]' R31+tlrc'[2]' \
ac35 R32+tlrc'[1]' R32+tlrc'[2]' \
ac36 R34+tlrc'[1]' R34+tlrc'[2]' \
ac37 R36+tlrc'[1]' R36+tlrc'[2]' \
ac38 R40+tlrc'[1]' R40+tlrc'[2]' \
ac39 R42+tlrc'[1]' R42+tlrc'[2]' \
ac40 R43+tlrc'[1]' R43+tlrc'[2]' \
ac41 R44+tlrc'[1]' R44+tlrc'[2]' \
-max_zeros 0.5   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-mask  Amask2+tlrc \
-HKtest \
-unequal_variance \
-prefix REML-GroupResults_MNI_MEMA_amygCont24

# Cont26------------------------
rm REML-GroupResults_MNI_MEMA_amygCont*
3dMEMA \
-groups Lateral Medial \
-set   Lateral \
ac1 R6+tlrc'[1]' R6+tlrc'[2]' \
ac2 R12+tlrc'[1]' R12+tlrc'[2]' \
ac3 R14+tlrc'[1]' R14+tlrc'[2]' \
ac4 R21+tlrc'[1]' R21+tlrc'[2]' \
ac5 R22+tlrc'[1]' R22+tlrc'[2]' \
ac6 R25+tlrc'[1]' R25+tlrc'[2]' \
ac7 R28+tlrc'[1]' R28+tlrc'[2]' \
ac8 R30+tlrc'[1]' R30+tlrc'[2]' \
ac9 R33+tlrc'[1]' R33+tlrc'[2]' \
ac10 R35+tlrc'[1]' R35+tlrc'[2]' \
ac11 R37+tlrc'[1]' R37+tlrc'[2]' \
ac12 R38+tlrc'[1]' R38+tlrc'[2]' \
ac13 R2+tlrc'[1]' R2+tlrc'[2]' \
-set Medial \
ac14 R4+tlrc'[1]' R4+tlrc'[2]' \
ac15 R5+tlrc'[1]' R5+tlrc'[2]' \
ac17 R11+tlrc'[1]' R11+tlrc'[2]' \
ac18 R13+tlrc'[1]' R13+tlrc'[2]' \
ac19 R15+tlrc'[1]' R15+tlrc'[2]' \
ac21 R17+tlrc'[1]' R17+tlrc'[2]' \
ac22 R18+tlrc'[1]' R18+tlrc'[2]' \
ac23 R19+tlrc'[1]' R19+tlrc'[2]' \
ac24 R20+tlrc'[1]' R20+tlrc'[2]' \
ac25 R23+tlrc'[1]' R23+tlrc'[2]' \
ac26 R24+tlrc'[1]' R24+tlrc'[2]' \
ac28 R27+tlrc'[1]' R27+tlrc'[2]' \
ac29 R29+tlrc'[1]' R29+tlrc'[2]' \
ac30 R31+tlrc'[1]' R31+tlrc'[2]' \
ac31 R32+tlrc'[1]' R32+tlrc'[2]' \
ac32 R34+tlrc'[1]' R34+tlrc'[2]' \
ac33 R36+tlrc'[1]' R36+tlrc'[2]' \
ac34 R39+tlrc'[1]' R39+tlrc'[2]' \
ac35 R40+tlrc'[1]' R40+tlrc'[2]' \
ac36 R42+tlrc'[1]' R42+tlrc'[2]' \
ac37 R43+tlrc'[1]' R43+tlrc'[2]' \
ac38 R44+tlrc'[1]' R44+tlrc'[2]' \
ac39 R45+tlrc'[1]' R45+tlrc'[2]' \
ac40 R46+tlrc'[1]' R46+tlrc'[2]' \
ac4 R1+tlrc'[1]' R1+tlrc'[2]' \
-max_zeros 0.5   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-mask  Amask2+tlrc \
-HKtest \
-prefix REML-GroupResults_MNI_MEMA_amygCont


# PT384
rm REML-PT384_MNI_MEMA*
3dMEMA \
-jobs 4 \
-set  ES \
ac1 R31+tlrc'[1]' R31+tlrc'[2]' \
ac3 R33+tlrc'[1]' R33+tlrc'[2]' \
-max_zeros 0.75   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-mask  AmaskD+tlrc \
-HKtest \
-prefix REML-PT384_MNI_MEMA


################################################
#   MEMA group analysis CIT168 parcellation
rm REML-GroupResults_MNI_MEMA_amygFIT*
3dMEMA \
-jobs 4 \
-set  ES \
ac1 R1+tlrc'[1]' R1+tlrc'[2]' \
ac2 R2+tlrc'[1]' R2+tlrc'[2]' \
ac3 R4+tlrc'[1]' R4+tlrc'[2]' \
ac4 R5+tlrc'[1]' R5+tlrc'[2]' \
ac5 R6+tlrc'[1]' R6+tlrc'[2]' \
ac6 R7+tlrc'[1]' R7+tlrc'[2]' \
ac7 R10+tlrc'[1]' R10+tlrc'[2]' \
ac8 R11+tlrc'[1]' R11+tlrc'[2]' \
ac9 R12+tlrc'[1]' R12+tlrc'[2]' \
ac10 R14+tlrc'[1]' R14+tlrc'[2]' \
ac11 R15+tlrc'[1]' R15+tlrc'[2]' \
ac13 R16+tlrc'[1]' R16+tlrc'[2]' \
ac14 R17+tlrc'[1]' R17+tlrc'[2]' \
ac15 R18+tlrc'[1]' R18+tlrc'[2]' \
ac16 R19+tlrc'[1]' R19+tlrc'[2]' \
ac17 R20+tlrc'[1]' R20+tlrc'[2]' \
ac19 R23+tlrc'[1]' R23+tlrc'[2]' \
ac20 R24+tlrc'[1]' R24+tlrc'[2]' \
ac21 R25+tlrc'[1]' R25+tlrc'[2]' \
ac23 R26+tlrc'[1]' R26+tlrc'[2]' \
ac24 R27+tlrc'[1]' R27+tlrc'[2]' \
ac25 R28+tlrc'[1]' R28+tlrc'[2]' \
ac27 R31+tlrc'[1]' R31+tlrc'[2]' \
ac28 R32+tlrc'[1]' R32+tlrc'[2]' \
ac29 R33+tlrc'[1]' R33+tlrc'[2]' \
ac30 R34+tlrc'[1]' R34+tlrc'[2]' \
ac33 R37+tlrc'[1]' R37+tlrc'[2]' \
ac34 R38+tlrc'[1]' R38+tlrc'[2]' \
ac35 R39+tlrc'[1]' R39+tlrc'[2]' \
ac36 R40+tlrc'[1]' R40+tlrc'[2]' \
ac37 R41+tlrc'[1]' R41+tlrc'[2]' \
ac38 R42+tlrc'[1]' R42+tlrc'[2]' \
ac39 R44+tlrc'[1]' R44+tlrc'[2]' \
ac40 R45+tlrc'[1]' R45+tlrc'[2]' \
ac41 R46+tlrc'[1]' R46+tlrc'[2]' \
-max_zeros 0.75   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-HKtest \
-prefix REML-GroupResults_MNI_MEMA_FITALL

################################################
#   MEMA group analysis CIT168 parcellation with rejected runs
rm REML-GroupResults_MNI_MEMA_FIT*
3dMEMA \
-jobs 4 \
-set  ES \
ac2 R2+tlrc'[1]' R2+tlrc'[2]' \
ac3 R4+tlrc'[1]' R4+tlrc'[2]' \
ac4 R5+tlrc'[1]' R5+tlrc'[2]' \
ac7 R10+tlrc'[1]' R10+tlrc'[2]' \
ac8 R11+tlrc'[1]' R11+tlrc'[2]' \
ac9 R12+tlrc'[1]' R12+tlrc'[2]' \
ac10 R14+tlrc'[1]' R14+tlrc'[2]' \
ac11 R15+tlrc'[1]' R15+tlrc'[2]' \
ac13 R16+tlrc'[1]' R16+tlrc'[2]' \
ac15 R18+tlrc'[1]' R18+tlrc'[2]' \
ac16 R19+tlrc'[1]' R19+tlrc'[2]' \
ac17 R20+tlrc'[1]' R20+tlrc'[2]' \
ac19 R23+tlrc'[1]' R23+tlrc'[2]' \
ac20 R24+tlrc'[1]' R24+tlrc'[2]' \
ac21 R25+tlrc'[1]' R25+tlrc'[2]' \
ac23 R26+tlrc'[1]' R26+tlrc'[2]' \
ac24 R27+tlrc'[1]' R27+tlrc'[2]' \
ac25 R28+tlrc'[1]' R28+tlrc'[2]' \
ac27 R31+tlrc'[1]' R31+tlrc'[2]' \
ac28 R32+tlrc'[1]' R32+tlrc'[2]' \
ac29 R33+tlrc'[1]' R33+tlrc'[2]' \
ac33 R37+tlrc'[1]' R37+tlrc'[2]' \
ac35 R39+tlrc'[1]' R39+tlrc'[2]' \
ac36 R40+tlrc'[1]' R40+tlrc'[2]' \
ac38 R42+tlrc'[1]' R42+tlrc'[2]' \
ac39 R44+tlrc'[1]' R44+tlrc'[2]' \
ac40 R45+tlrc'[1]' R45+tlrc'[2]' \
ac41 R46+tlrc'[1]' R46+tlrc'[2]' \
-max_zeros 0.1   \
-no_model_outliers \
-residual_Z \
-missing_data 0 \
-HKtest \
-prefix REML-GroupResults_MNI_MEMA_FITCIT











#########################################
# COPY freesurfer files in the directly "HGv3"

# SURFACE preparation .........
cd /home/hiroyuki/es-fMRI/AMYG/amy

# Make Brain only image ........
3dcalc -a mni_icbm152_t1_tal_nlin_asym_09c.nii \
-b mni_icbm152_t1_tal_nlin_asym_09c_mask.nii \
-expr '(a*b)' -prefix mni_icbm152_brain

# Create Spec file (Needs freesurfer processed surf folder to be copied).........
rm -R ./SUMA
@SUMA_Make_Spec_FS -sid icbm152_09c_asym -fspath ~/es-fMRI/AMYG -GIFTI -inflate 300  

# Do AlignToExperiment ...........
cd /home/hiroyuki/es-fMRI/AMYG/amy
rm  ./norm_shft.nii*
@SUMA_AlignToExperiment \
-exp_anat mni_icbm152_brain+tlrc \
-surf_anat ~/es-fMRI/AMYG/SUMA/icbm152_09c_asym_SurfVol.nii \
-prefix icbm152_ALEXP

# ////////    Visualize Response on the surface   //////////#
cd /home/hiroyuki/es-fMRI/AMYG/amy
afni -niml &
suma -spec ~/es-fMRI/AMYG/SUMA/icbm152_09c_asym_both.spec -sv ./icbm152_ALEXP+tlrc

cd /home/hiroyuki/es-fMRI/AMYG/amy
cp ~/AMYG/412/1/FMRIPREP_MNI_412_1_BLOCK_6mm_TcompcorFD+tlrc.* 


# Hit " . " key change the surface
# Hit "t" to talk
# Ctl+Shift+r to take a picture
# F6 = back ground color
# F8 = perspective on/off
# F3 = cursor point off



############################
cd ~/es-fMRI/AMYG/412/1
rm AutoMASK+tlrc*
3dAutomask -nbhrs 13 -peels 0 -erode 0 -prefix AutoMASK meanBOLD+tlrc 
cp AutoMASK+tlrc ~/es-fMRI/AMYG/amy/AutoMASK+tlrc

3dcalc -a FMRIPREP_MNI_412_1_BLOCK_6mm_TcompcorFD+tlrc \
-b AutoMASK+tlrc \
-expr '(a*b)' -prefix masked-FMRIPREP_MNI_412_1_BLOCK_6mm_TcompcorFD+tlrc




# ATLAS 
cd ~/es-fMRI/AMYG/330/7
cp ~/es-fMRI/AMYG/303/1/AAL2.nii ./
rm AAL2REG*
3dresample -master filt-HSBM6mm+tlrc \
    -prefix AAL2REG \
    -input AAL2.nii
# For power calculation .....
roi=6001
3dmaskdump -mask AAL2REG+tlrc -quiet -mrange $roi $roi filt-HSBM6mm+tlrc  > roi$roi.txt
3dmaskave -mask AAL2REG+tlrc -sigma -quiet -mrange $roi $roi filt-HSBM6mm+tlrc > mroi$roi.txt 























# Bash for loop --------------
for ((k=40;k<=45;k++))
do
  echo "---------------------"  
  run=${runlist[$k]}
  pt=${ptlist[$k]}
  echo "    " $((k+1)) ":" $pt "-" $run
  echo "    "
done
  

afni -niml &
suma -spec ~/es-fMRI/pt384/SUMA/pt384_both.spec -sv ./001ALEXP+orig














cd ~/es-fMRI/icbm152/SUMA
ConvertDset -o_gii -input 'std.60.lh.curv.niml.dset' -prefix curv_60LH
ConvertDset -o_gii -input 'std.60.rh.curv.niml.dset' -prefix curv_60RH


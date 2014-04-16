# Cambridge memory test for faces

## 2014 04 10 
### ROIs
 * `drawROI` pulls from `ROImatout.txt`
   * try e.g. `drawROI(1)` and adjusting ROImatout.txt 

### Rescoring
```matlab
 % add ilab to path
 addpath(genpath('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award Preparation/TASKS IN USE/FACES_ROI_INFO/Kirsten_Faces_ILab/ilab-3.6.8'))
 % rescore a single person (from output of jens scoring
 rescorethisdataCMFT('subj_eyemats/will_drift.mat')
 % view
 plotFixations('rescored/will_drift.mat',1:2)
 % rescore everyone
 rescoreAll
```

### TODO
 * ~~condition 3 memory is included in condition 2 test~~ trial 63 condition changed to 3
 
## Paradigm
 Participants push a button to identify which face belongs to a previously memorized face. The paradigm has 3 variations (conditions) each with 2 phases (types): (1) memory and (2) recall.

 See `ROImatout.txt`

Cond | mem  | recall
-----|------|-------
1    | 6(x3)| 6(x3) 
2    | 1    | 30
3    | 1    | 24

### Condition 1 
There are 18 memorization + recall events

1. *Memorization*: 3 slides are presented one at a time for 3 seconds each. Each slide shows the same face from a different angle.
2. *Recall*:  a slide with 3 faces is presented. The participate is asked to push 1,2, or 3 to indicate which face was memorized. This happens 3 times.

### Condition 2 and 3
There are 30 recalls in condition 2 and 24 in condition 3.

1. *Memorization*: one slide with 6 previously seen faces 
2. *Recall*:  same as before but with **xx** repeats instead of 3.
 
### Manipulations
 Some recall faces are noisy.

## Original
```text
***************************** 
 Have moved scorethisdataCMFT and ilabMkFixationList.m from ilab directory into here!
   so order of add path is now important
 1. addpath(ilab)
 2. addpath(andrew)
***************************** 

Scorers run: 
  scorethisdataCMFT.m

Data in:
  B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/Raw Data/Year1/Cambridge Face Task/

Scripts in:
  B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/CMFT_EYE_SCRIPTS/
  B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award Preparation/TASKS IN USE/FACES_ROI_INFO/Kirsten_Faces_ILab/ilab-3.6.8

XDATS:

1             -- fix
3             -- practice
8             -- start
9             -- stop
[4..6]        -- pratice memory: left center right
[1..6][1..3]  -- memory: 1..6: person, 1..3: angle
72            -- memory: all at once
1[1..6][1..3] -- test:   same scheme as memory 


USAGE:
 
 %% add ilab and scripts
 addpath(genpath('andrewOnB'))
 addpath(genpath('ilab-3.6.8'))
 % B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/CMFT_EYE_SCRIPTS/
 % B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award Preparation/TASKS IN USE/FACES_ROI_INFO/Kirsten_Faces_ILab/ilab-3.6.8

 %% open and preprocess in ilab
 %% 
 >> ilab 
 file -> convert convert file ..
 [ select ASL, edit trials, etc]
 Analysis -> Blinks, Filters [??gausain at what?? -- 9 and 7 AL]
 Analysis -> Data to workspace [check all?]


 %% run davids stuff
 scorethisdataCMFT.m


CODE:

 %% score exported data
 scorethisdataCMFT:

    %%% Setup AP
    ilabGetAnalysisParms 'get'->'reset'
       global ANALYSISPARMS

       ilabDefaultAnalysisParms: define AP
          filter fix coord gap blink gaze 
          roi  saccade screen trialcodes

           AP.screen.distance = 56, AP.saccade.velThresh=30


       ilabRegisterFilters
       ilabGetROI
       ilabSetAnlysisParms



    %%% Setup PP
    ilabGetPlotParms('get') -> ilablGetPlotParms('reset')
       ilabDefaultPlotParms
          PLOTPARMS: axis and cooridnates
          PP.data:  x y xdat pupil
          PP.index: startIndx targetIndx stopIndx  %indx in data

    
    %%% DM: use fixation to adjust for drift
    %% takes fixation as function input
    ilabGetDriftCorrectedPlotParms
     args = ( AP, PP, fixationCoords, fixationXDAT, minFixSamples  )
                           [320,230],            3,            20


       for each row in PP.index
        if it's a fixation, use this up to the end of the next trial
        guess at center using valid points (> sac velocity)
        
    %%% Score trials
    ilabExtractTrialData
         read from excel :(
```

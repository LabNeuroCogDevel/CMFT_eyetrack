
%%
% 2013-04-12
%
% Find what a subject is staring at 
% with fixation based on dispersion model (?)
%
% TODO: record addpath(genpath()) commands that precede calling this script
%
% addpath(genpath('/home/foranw/src/ilab/ilab-3.6.9/'))
% addpath(genpath('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/CMFT_EYE_SCRIPTS'))
%
% major final output will be in workspace as data.roi and data.fix
% there is also data.missing which is also written to ${subjectID}-DROPPED.csv
%
% data.roi is colums
%   TODO: write up
% data.fix is columns
%   TODO:write up
% data.missing 
%   TODO: write up
%
%
% TODO: possible bug: seen xdats are built after fixations
%       XDAT in PP.data but not in fixationTable will be skipped
%       and all of the matching XDATs in that phase will be dropped
%       SOLUTION: build xdatrep with PP.data when creating fixationTable
%
%
% Process is documented somewhat in readme, highlights are:
%  * run ilab, pick subject data
%  * run disp. method to get fixations
%  * read xls file with per xdat/phase/occurance face rois (up to 6 faces)
%  * label fixation as face, eyes, nose, mouth, or NA
%  * count times in ROIs
%
%%


global subjectID ILAB
subjectID=input('subjectID: ','s');


%%%% Automate button pushing when we have a subject ID
% stole from previous attempt in:
% /mnt/B/bea_res/Oxford Eye Experiments/Scoring/Scoring Programs/final scoring programs/031708 Behavioral Bars scoring programs/ilab_behavBars.m

% global ANALYSISPARMS PLOTPARMS  REVUI_SAVE_NEEDED REVUI_ILAB;
% 
% %% copied from ilab.m (B/bea_res/Oxford Eye Experiments/Oxford Eye Lab/ILAB/ILAB-3.6.4/)
% AP = ilabGetAnalysisParms;
% % register any filters
% AP.filter = ilabRegisterFilters(AP);
% 
% ilabSetAnalysisParms(AP);
% 
% hMainWin = ilabNewMainWin;
% 
% %% set bars behavior trial codes
% %TODO: check these
% ANALYSISPARMS.trialCodes.start  = 8;
% ANALYSISPARMS.trialCodes.target = [1:7,10:116];
% ANALYSISPARMS.trialCodes.end    = 9;
% 
% 
% 
% %% load eyd
% % TODO-interface: use subject id to find eyd
% [fname, pname]=uigetfile;
% if(~fname); break; end
% 
% %% ilab config params 
% % We know our files are ASL v6, and we want ASL->PC for coords 
% ILAB = ilabConvertASL(pname,fname,6);
% ILAB.coordSys = AP.coordSys(2);
% REVUI_ILAB = ILAB;
% % We don't want to save
% REVUI_SAVE_NEEDED = 0;
% 
% %% launch ilab
% % launch menu
% ilabInitReviewILABUI(ILAB);
% 
% fprintf('waiting for data ...\n')
%  while(size(PLOTPARMS.data,2)<1)
%      pause(3)
%  end
% %% %ilabVelocityPlotCB_keys % modified version that has key presses 
% %% % could use set/get to do this
% %% 
% %% %%% wouldn't it be nice to only launch the menu if ckStartStopCnt fails
% %% % push okay if everything is okay, prompt menu otherwise
% %% % try 
% %% %  ilabReviewILABCB('ok', ILAB);
% %% % catch
% %% %  ilabInitReviewILABUI(ILAB);
% %% % end
% %% 
% %% %%
% %% 
% %% %% wait for saccades to be exported to workspace by ilab/user
% %% % this implies user is done scoring
% %% fprintf('waiting for "File->Toolbox->xtractSaccades"...\n')
% %%  while(~exist('saccades','var'))
% %%    pause(3)
% %%  end
% %% 
% %% %% table of saccades
% %% % from ilabSaveTblAsExcelCB (callback in ilabNewMainWin from Analysis->save as )
% %% %table = ilabMkSaccadeTbl(AP.saccade.list, 'spreadsheet'); 
% %% %table = ilabMkSaccadeTbl(ANALYSISPARMS.saccade.list,'spreadsheet');
% %% %table{1}
% %% %Trial	Sacc#	Start	End	peak vel	mean vel	sac React Time	time-to-Peak	dist(deg)	%Zero
% %% table = ANALYSISPARMS.saccade.list;
% %% PP    = PLOTPARMS;


%%%% Actual scoring -- original setup by David Montez
%function scorethisdataCMFT
%    global AP origPP driftPP data
    AP = ilabGetAnalysisParms;
    origPP = ilabGetPlotParms;
    
    
    %320,230 is fixation center
    %driftPP = ilabGetDriftCorrectedPlotParms(AP, origPP, [320,230], 3, 20);
    % GetDriftCorrected is called from withint Extract function
    % so we ignore dritfPP
    
    [data,xdatlist,fixtab] = ilabExtractTrialData(AP,origPP,true);
    [data_nodrift,~,fixtab_nodrift] = ilabExtractTrialData(AP,origPP,false);
    % WF 20140130: changed to drift correction == TRUE, now save output
    matfile=[subjectID '_drift.mat'];
    save(matfile,'subjectID','AP','origPP','xdatlist','fixtab','data','fixtab_nodrift','data_nodrift','ILAB')
%end
  
   plotFixations(matfile);

%in lue of above try:
% cd('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/CMFT_EYE_SCRIPTS/')
% andrew looked at the mouth the  whole time
% load('example/andrew_drift_orig.mat'); 
% addpath(genpath('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award Preparation/TASKS IN USE/FACES_ROI_INFO/Kirsten_Faces_ILab/ilab-3.6.8/' ) )
% addpath(genpath(pwd))
% [data, xdatlist,fixtab] = ilabExtractTrialData(AP, origPP,true);
% [data_nodrift,~,fixtab_nodrift] = ilabExtractTrialData(AP,origPP,false);
% 


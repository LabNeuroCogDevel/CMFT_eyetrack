function [results,XDATList, fixationTable, driftvector ] = ilabExtractTrialData(AP,PP,applyDriftCorrect)

global subjectID

if ~islogical(applyDriftCorrect)
    error('A boolean argument, indicating whether or not to apply a drift correction, must be supplied.\n')
end

% Coordinates are not exact center, which would be [320,240] because
% fixation cross is offset by 10 pixels vertically (why? who the fuck knows
% and it's too late to fix it.)
fixationCoords =                [320,230];
fixationXDAT =                  1;
minFixationSamples =            20;
msPerSample =                   1/60*100; %ilabGetAcqIntvl;

% INITIALIZE THE RESULTS STRUCTURE
results.roi = [];
results.fix = {};

% DATA TABLE FOR ROI DATA
roiData = [];

% DATA TABLE FOR FIXATION DATA
fixData = {};

% BUILD LIST OF TRIAL ROIS
%XDATList = ilabMakeTrialListFromExcel('B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award Preparation\TASKS IN USE\FACES_ROI_INFO\ROI_Final.xlsx','ROICoords');
scriptdir=fileparts(which('ilabExtractTrialData'));
%ROIFile = fullfile(scriptdir,'ROI','ROI_Final.xls');
%XDATList = ilabMakeTrialListFromExcel(ROIFile,'ROICoords');
XDATList  = readROItxt(fullfile(scriptdir,'ROImatout.txt'),fullfile(scriptdir,'ROI/imagelist.txt'));

% BUILD ROI COLLECTIONS
%ROIList = ilabMakeROIsFromExcelFile('B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award Preparation\TASKS IN USE\FACES_ROI_INFO\ROIs_photoshop.xls','ROIIDS_coordinates');
%ROIList = ilabMakeROIsFromExcelFile('B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award Preparation\TASKS IN USE\SUBI_ROI_INFO\SUBI_ROI_INFO.xlsx','SUBI_Seed_1_ROI_CT_INFO');
% UBI_Seed_1_ROI_CT_INFO ] [  SUBI_Seed_2_ROI_CT_INFO # for each seed/ user input?

% If the user wants to run the analysis on the drift corrected time courses
if applyDriftCorrect
    [PP, driftvector ] = ilabGetDriftCorrectedPlotParms(AP, PP, fixationCoords, fixationXDAT, minFixationSamples);
else
    driftvector = -1;
end

% EXTRACT THE FIXATIONS FROM THE CORRECTED PLOT PARMS
% (THIS REQIRES KIRSTENS CUSTOM ANALYSISPARMS)
fixationTable = ilabMkFixationList(PP.data,PP.index,AP); 
%AP argumented added in modified version, will error if path is wrong

% add condition and obseved repeats to fixation table
condition=1;
TOIv=zeros(length(fixationTable),2);

% hash for storing xdat occurance counts
repXDAT=zeros(1,163);
for o=1:length(fixationTable)
    xdat=fixationTable(o,9);
    if o > 1 && xdat ~= fixationTable(o-1,9) 
        
        
        %if ~ ismember(xdat,[1:6,114:116])
        if xdat == 72
          condition=condition+1;
          % re-zero all occurances of XDATs
          repXDAT=zeros(1,163); 
        %elseif fixationTable(o-1,9)== 72
    
            
        end
        
        repXDAT(xdat) = repXDAT(xdat)+1;
    end
    
    TOIv(o,:) = [ condition, repXDAT(xdat)];
    
end


%
% trialnum, x, y, 0, 0, data index of fix start, length in samples, 0 
%       xdat, condition, observed repeats in condition
%
fixationTable=[ fixationTable, TOIv ];



% LOOP THROUGH ALL FIXATIONS AND SEE IF THEY OCCURED WITHIN AN ROI FOR THAT
% TRIAL.
for i=1:size(fixationTable,1)
    
    trialNum = fixationTable(i,1);
    cond = fixationTable(i,10);
    occurance = fixationTable(i,11);
    meanx_coord = fixationTable(i,2);
    meany_coord = fixationTable(i,3);
    fixLatency = fixationTable(i,6) * msPerSample;
    fixDuration = fixationTable(i,7) * msPerSample;
    ROIType = '';
    
    startIndex = PP.index(trialNum,1);
    endIndex = PP.index(trialNum,2);
    targetIndex = PP.index(trialNum,3);
    trialData = PP.data(targetIndex,:);
    xdatCode = trialData(1,3);
 
    trialROIs = [];
    trialType = [];
    % Get the list of ROIs associated with the XDAT code for this trial
    
    for k=1:size(XDATList,2)
        if xdatCode == XDATList(k).XDAT && cond == XDATList(k).condition && occurance == XDATList(k).occurance;
            trialType = XDATList(k).trialtype;
            
            % need 1:6 for each set of face rois
            ROI=XDATList(k);
            ROIType=0;
            for ROInum=1:6 
                for ROItype={'face','eyes','mouth','nose'}
                    ROItype=ROItype{1};
                    %ROInum, ROItype
                    if isempty(ROI.(['x' num2str(ROInum)]))
                        %fprintf('%d %d is empty\n',k,ROInum) 
                        continue
                    end
                    x=ROI.(['x' num2str(ROInum)]).(ROItype); 
                    y=ROI.(['y' num2str(ROInum)]).(ROItype); 
                    w=ROI.(['w' num2str(ROInum)]).(ROItype); 
                    h=ROI.(['h' num2str(ROInum)]).(ROItype); 
                    %ROI.(['x' ROInum])
                    % Check to see if the the fixation lies within this ROI
                    if meanx_coord >= x && ...
                       meanx_coord <= x + w && ...
                       meany_coord >= y && ...
                       meany_coord <= y + h
                       
                       ROIType=ROItype;
%                         % Check to see if the fixation lies within they
%                         % eyes,nose, or mouth sub-ROIs                  
%                         if     meanx_coord >= ROI.eyes.x && ...
%                                meanx_coord <= ROI.eyes.x + ROI.eyes.w && ...
%                                meany_coord >= ROI.eyes.y && ...
%                                meany_coord <= ROI.eyes.y + ROI.eyes.h
%                         
%                             ROIType = 'eyes';
%                         elseif meanx_coord >= ROI.nose.x && ...
%                                meanx_coord <= ROI.nose.x + ROI.nose.w && ...
%                                meany_coord >= ROI.nose.y && ...
%                                meany_coord <= ROI.nose.y + ROI.nose.h
%                             
%                            ROIType = 'nose';
%                             
%                         elseif meanx_coord >= ROI.mouth.x && ...
%                                meanx_coord <= ROI.mouth.x + ROI.mouth.w && ...
%                                meany_coord >= ROI.mouth.y && ...
%                                meany_coord <= ROI.mouth.y + ROI.mouth.h                        
%                            
%                            ROIType = 'mouth';
%                         
%                         else
%                             
%                             ROIType = 'face';
%                         
%                         end
                        
                    end
                end 
            end % should have labeled this fixation
            if ROIType ~= 0
             fixData = cat(1, fixData,{trialNum,0,meanx_coord,meany_coord,fixLatency,fixDuration,ROIType,cond,trialType,xdatCode});
             break % useless.. already did all of the for loops
            end
        end
    end
    
    %if ~isempty(trialROIs) && ~isempty(trialType)
        
%         for j=1:size(trialROIs,1)
%             
%             ROIID = trialROIs(j);
%             
%             for m=1:size(ROIList,2)
%                 
%                 if ROIList(m).ROIID == ROIID
%                     
%                     ROI = ROIList(m);
%                     
% 
%                     
%                 end
%                 
%             end
%             
%         end
%         
%     end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%start building the%%%%%%%%%%%%%%%%%%%%%%next%%%%%%%%%%%%%%%%%%%%list%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assign condition and number of repeats for an xdat
condition=1;
TOIv=zeros(length(fixationTable),2);
% hash for storing xdat occurance counts
repXDAT=zeros(1,163);

% LOOP THROUGH EACH TRIAL
    for i=1:size(PP.index,1)
        % break % meh, don't do this stuff ...yet

        % reset the trial info variables
        trialType =[];
        trialROIs = [];
        startIndex = PP.index(i,1);
        endIndex = PP.index(i,2);
        targetIndex = PP.index(i,3);

        % Extract the trail data from the raw data
        trialData = PP.data(targetIndex:(endIndex-1), : );
        xdatCode = trialData(1,3);

        %%% increment condition and redo trial repeat numbers
        if xdatCode == 72
            condition=condition+1;
            % re-zero all occurances of XDATs
            repXDAT=zeros(1,163);
        end
        repXDAT(xdatCode) = repXDAT(xdatCode)+1;
        occurance=repXDAT(xdatCode);
        trialType = 1;
        if xdatCode >= 100, trialType=2; end
        % now have condition and occurance to match cond and trialtype from xls

        % Get the list of ROIs associated with the XDAT code for this trial
        for k=1:size(XDATList,2)
            trialinfo = XDATList(k);
            if xdatCode == trialinfo.XDAT && condition == trialinfo.condition ...
                    && occurance == trialinfo.occurance
                trialType = XDATList(k).trialtype;

                %disp('match')
                %xdatCode, condition, occurance,
                % If this trial has an XDAT code that is in the XDATList table, then
                % data needs to be extracted from it.
                %     if ~isempty(trialType) && ~isempty(trialROIs)

                % Loop through the ROIIDs associated with this XDAT code
                %         for l=1:size(trialROIs,1)
                %
                %             ROIID = trialROIs(l);
                %
                %             % Find the ROI referred to by ROIID
                %             for m=1:size(ROIList,2)

                % for ROInum=1:6

                %                     if ROIList(m).ROIID == ROIID
                %                     ROI = ROIList(m);
                %
                %                     ROI.ROIID;
                %
                ROI=XDATList(k);
                %times.face=0;
                %times.eyes=0;
                %times.mouth=0;
                %times.nose=0;
                % TODO: why doesn't this work!?
                for ROInum=1:6
                    for ROItype={'face','eyes','mouth','nose'}
                        ROItype=ROItype{1};
                        if isempty(ROI.(['x' num2str(ROInum)]))
                         %fprintf('%d %d is empty\n',k,ROInum) 
                         continue
                        end
                        times.(ROItype)=0;
                        %ROInum, ROItype
                        x=ROI.(['x' num2str(ROInum)]).(ROItype);
                        y=ROI.(['y' num2str(ROInum)]).(ROItype);
                        w=ROI.(['w' num2str(ROInum)]).(ROItype);
                        h=ROI.(['h' num2str(ROInum)]).(ROItype);
                        
                        
                                                %ROI.(['x' ROInum])
                        % Check to see if the the fixation lies within this ROI
                         indexes = ...
                                trialData(:,1) >= x & ...
                                trialData(:,1) <= x + w & ...
                                trialData(:,2) >= y & ...
                                trialData(:,2) <= y + h;
                            
                         times.(ROItype) =  size( find(indexes), 1) ...
                                               * msPerSample;
                        
                    end
                    
                    % dont record (or even try) when there isn't an ROI
                    % based on last xy wh  which should be nose (and allf
                    % faces have a nose)
                    if ~any([x,y,w,h])
                        
                        continue
                    end
                    
                    roiData = cat(1,roiData,[i xdatCode trialType condition ROInum times.face times.eyes times.nose times.mouth]);

                end
                % and combine with summary matrix
                % face is less constrained -- includes eyes nose mouth
                % times in addition to time only in face
                % to change: times.face= times.face - times.eyes -
                % times.mouth ....
                 

                            %%% DAVIDS SH*T %%%
                            %                     % Extract all of the sample points where the subjects was looking
                            %                     % inside of the main ROI (whole face area)
                            %                     faceDataIndex = trialData(:,1) >= ROI.x & ...
                            %                                     trialData(:,1) <= ROI.x + ROI.w & ...
                            %                                     trialData(:,2) >= ROI.y & ...
                            %                                     trialData(:,2) <= ROI.y + ROI.h;
                            %
                            %                     faceData = trialData(faceDataIndex,:);
                            %                     faceTime = size(faceData,1) * msPerSample;
                            %                     %Extract from the whole face ROI the amount of time spent looking
                            %                     %at the sub ROIs (eyes, nose, mouth)
                            %
                            %                     % EYES
                            %                     eyesDataIndex = faceData(:,1) >= ROI.eyes.x & ...
                            %                                     faceData(:,1) <= ROI.eyes.x + ROI.eyes.w & ...
                            %                                     faceData(:,2) >= ROI.eyes.y & ...
                            %                                     faceData(:,2) <= ROI.eyes.y + ROI.eyes.h;
                            %
                            %                     eyesData = faceData(eyesDataIndex,:);
                            %                     eyesTime = size(eyesData,1) * msPerSample;
                            %
                            %                     % NOSE
                            %                     noseDataIndex = faceData(:,1) >= ROI.nose.x & ...
                            %                                     faceData(:,1) <= ROI.nose.x + ROI.nose.w & ...
                            %                                     faceData(:,2) >= ROI.nose.y & ...
                            %                                     faceData(:,2) <= ROI.nose.y + ROI.nose.h;
                            %
                            %                     noseData =  faceData(noseDataIndex,:);
                            %                     noseTime = size(noseData,1)* msPerSample;
                            %
                            %                     % MOUTH
                            %                     mouthDataIndex = faceData(:,1) >= ROI.mouth.x & ...
                            %                                      faceData(:,1) <= ROI.mouth.x + ROI.mouth.w & ...
                            %                                      faceData(:,2) >= ROI.mouth.y & ...
                            %                                      faceData(:,2) <= ROI.mouth.y + ROI.mouth.h;
                            %
                            %                     mouthData = faceData(mouthDataIndex,:);
                            %                     mouthTime = size(mouthData,1) * msPerSample;
                            %
                            %
                            %                     roiData = cat(1,roiData,[i xdatCode trialType ROIID faceTime eyesTime noseTime mouthTime]);

                %else
                %disp(['XDAT code:',num2str(xdatCode),' is not present in XDATList'])          
            end
        end                
    end
 
% check max occurances against expected max occurances
fixationXdatOccurMax=zeros(0,3); 
for cond=1:3; 
    percond=fixationTable(fixationTable(:,10)==cond,:); 
    for xdat=unique(percond(:,9))'; 
        if( ismember( xdat ,[1:9,114,116] ) ); continue; end  
        if( xdat==115 && cond==1  ); continue; end  
        fixationXdatOccurMax=[fixationXdatOccurMax; ...
                cond, xdat, max(percond(percond(:,9)==xdat,11))];   
    end; 
end;

%fixationXdatOccurMax

% build occurances (redudant!)
t=zeros(length(XDATList),3); 
for i=1:length(XDATList); 
    t=[t; XDATList(i).condition XDATList(i).occurance XDATList(i).XDAT ];
end

% find max values in expected occurances
expectedXdatOccurMax=zeros(0,3);
for cond=1:3;
    percond=t(t(:,1)==cond,:); 
    for xdat=unique(percond(:,3))'; 
        expectedXdatOccurMax=[expectedXdatOccurMax; ...
           cond, xdat, max(percond(percond(:,3)==xdat,2))];   
    end; 
end;

% dont know where this came from -- but it's always in fixationXdatOccurMax
expectedXdatOccurMax = [expectedXdatOccurMax; 3 72 1];

missing = setdiff(fixationXdatOccurMax,expectedXdatOccurMax,'rows');
%
% REMOVE fixations and rois when that xdat is too ambigious
%
if(~isempty(missing))
   errfile=fopen([subjectID '-DROPPED.csv'],'w');
   fprintf(errfile,'cond,xdat,numberXDATrepeatsSeen\n');
   %for i=1:length(missing)
   for i=1:size(missing,1)
       cond=missing(i,1);xdat=missing(i,2);%max=missing(i,3);

       fixidx=  find(cell2mat(fixData(:,10))== xdat & cell2mat(fixData(:,8))== cond) ;
       roiidx=  find(         roiData(:,2)  == xdat &          roiData(:,4) == cond );

       fprintf('Missing XDAT: %d\t%d\t%d -- dropping\n',missing(i,:))
       fprintf(errfile,'%d,%d,%d\n',missing(i,:));
       
       fixData(fixidx )=[];
       %fixData(fixidx,: )=[];
       roiData(roiidx,: )=[];
   end
   fclose(errfile);
end


results.roi     = roiData;
results.fix     = fixData;
results.missing = missing;

%TODO: what xdat+occurances+condtion max's in XDATList don't match -- print
%out which are dropped -- drop those
% TODO: go back and put roinum in fixation output too!

% TODO:
% check max occurances against expected max occurances
%  t=zeros(0,3); for cond=1:3; percond=fixationTable(find(fixationTable(:,10)==cond),:); for xdat=unique(percond(:,9))'; t=[t; cond, xdat, max(percond(find(percond(:,9)==xdat),11))];   end; end; t

% TODO: repXDAT should be built using PP.data and not fixationTable
% precurser

end



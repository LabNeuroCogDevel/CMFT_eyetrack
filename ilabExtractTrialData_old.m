function [results] = ilabExtractTrialData(driftCorrect)

% Coordinates are not exact center, which would be [320,240] because
% fixation cross is offset by 10 pixels vertically
fixationCoords =                [320,230];
fixationXDAT =                  3;
minFixationSamples =            20;
msPerSample =                   ilabGetAcqIntvl;


% INITIALIZE THE RESULTS STRUCTURE
results.roi = [];
results.fix = {};

% DATA TABLE FOR ROI DATA
roiData = [];

% DATA TABLE FOR FIXATION DATA
fixData = {};

% LOAD UP KIRSTEN'S ANALYSISPARMS STRUCTURE
% ilabSetAnalysisParms(ilabKirstenAnalysisParms)

% APPLY THE DRIFT CORRECTION ALGORITHM TO THE DATA
% PPs is a 1x2 structure of PLOTPARMS
% PPs(1) drift corrected PLOTPARMS
% PPs(2) original PLOTPARMS
PPs = ilabGetDriftCorrectedPlotParms(fixationCoords, fixationXDAT, minFixationSamples);

% INSERT THE CORRECTED PLOTPARMS BACK INTO ILAB
ilabSetPlotParms(PPs(1))

% EXTRACT THE FIXATIONS FROM THE CORRECTED PLOT PARMS
% (THIS REQIRES KIRSTENS CUSTOM ANALYSISPARMS)
fixationTable = ilabMkFixationList(PPs(1).data,PPs(1).index);

% BUILD LIST OF TRIAL ROIS
XDATList = ilabMakeTrialListFromExcel('B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award Preparation\TASKS IN USE\FACES_ROI_INFO\ROIs_photoshop.xls','XDAT_INFO');

% BUILD ROI COLLECTIONS
ROIList = ilabMakeROIsFromExcelFile('B:\bea_res\Personal\Andrew\Autism\Experiments & Data\K Award Preparation\TASKS IN USE\FACES_ROI_INFO\ROIs_photoshop.xls','ROIIDS_coordinates');

% If the user wants to run the analysis on the drift corrected time courses
% then the index to use is 1 (look at ilabGetDriftCorrectedPlotParms.m)
% Otherwise it is 2 (PlotParms that have not had the correction applied)
PPIDX = 1;
if strcmpi('drift', driftCorrect)
    PPIDX = 1;
else
    PPIDX = 2;
end



% LOOP THROUGH ALL FIXATIONS AND SEE IF THEY OCCURED WITHIN AN ROI FOR THAT
% TRIAL.

for i=1:size(fixationTable,1)
    
    trialNum = fixationTable(i,1);
    meanx_coord = fixationTable(i,2);
    meany_coord = fixationTable(i,3);
    fixLatency = fixationTable(i,6) * msPerSample;
    fixDuration = fixationTable(i,7) * msPerSample;
    ROIType = '';
    
    startIndex = PPs(PPIDX).index(trialNum,1);
    endIndex = PPs(PPIDX).index(trialNum,2);
    targetIndex = PPs(PPIDX).index(trialNum,3);
    trialData = PPs(PPIDX).data(targetIndex,:);
    xdatCode = trialData(1,3);

    
    
    trialROIs = [];
    trialType = [];
    % Get the list of ROIs associated with the XDAT code for this trial
    for k=1:size(XDATList,2)
        if xdatCode == XDATList(k).XDAT
            trialType = XDATList(k).trialtype;
            trialROIs = XDATList(k).ROIs;
            break
        end
    end
    
    if ~isempty(trialROIs) && ~isempty(trialType)
        
        for j=1:size(trialROIs,1)
            
            ROIID = trialROIs(j);
            
            for m=1:size(ROIList,2)
                
                if ROIList(m).ROIID == ROIID
                    
                    ROI = ROIList(m);
                    
                    % Check to see if the the fixation lies within this ROI
                    if meanx_coord >= ROI.x && ...
                       meanx_coord <= ROI.x + ROI.w && ...
                       meany_coord >= ROI.y && ...
                       meany_coord <= ROI.y + ROI.h
                        
                        % Check to see if the fixation lies within they
                        % eyes,nose, or mouth sub-ROIs                  
                        if     meanx_coord >= ROI.eyes.x && ...
                               meanx_coord <= ROI.eyes.x + ROI.eyes.w && ...
                               meany_coord >= ROI.eyes.y && ...
                               meany_coord <= ROI.eyes.y + ROI.eyes.h
                        
                            ROIType = 'eyes';
                        elseif meanx_coord >= ROI.nose.x && ...
                               meanx_coord <= ROI.nose.x + ROI.nose.w && ...
                               meany_coord >= ROI.nose.y && ...
                               meany_coord <= ROI.nose.y + ROI.nose.h
                            
                           ROIType = 'nose';
                            
                        elseif meanx_coord >= ROI.mouth.x && ...
                               meanx_coord <= ROI.mouth.x + ROI.mouth.w && ...
                               meany_coord >= ROI.mouth.y && ...
                               meany_coord <= ROI.mouth.y + ROI.mouth.h                        
                           
                           ROIType = 'mouth';
                        
                        else
                            
                            ROIType = 'face';
                        
                        end
                        
                        
                        fixData = cat(1, fixData,{trialNum,ROIID,meanx_coord,meany_coord,fixLatency,fixDuration,ROIType});
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end
    


% LOOP THROUGH EACH TRIAL
for i=1:size(PPs(PPIDX).index,1)
    
    % reset the trial info variables
    trialType =[];
    trialROIs = [];
    startIndex = PPs(PPIDX).index(i,1);
    endIndex = PPs(PPIDX).index(i,2);
    targetIndex = PPs(PPIDX).index(i,3);

    % Extract the trail data from the raw data
    trialData = PPs(PPIDX).data(targetIndex:endIndex,:);
    
    xdatCode = trialData(1,3);

    % Get the list of ROIs associated with the XDAT code for this trial
    for k=1:size(XDATList,2)
        if xdatCode == XDATList(k).XDAT
            trialType = XDATList(k).trialtype;
            trialROIs = XDATList(k).ROIs;
            break
        end
    end
    
    
    % If this trial has an XDAT code that is in the XDATList table, then
    % data needs to be extracted from it.
    if ~isempty(trialType) && ~isempty(trialROIs)
        
        % Loop through the ROIIDs associated with this XDAT code
        for l=1:size(trialROIs,1)
            
            ROIID = trialROIs(l);
            
            % Find the ROI referred to by ROIID
            for m=1:size(ROIList,2)
                
                if ROIList(m).ROIID == ROIID
                ROI = ROIList(m);
                
                ROI.ROIID;
        
                % Extract all of the sample points where the subjects was looking
                % inside of the main ROI (whole face area)
                faceDataIndex = trialData(:,1) >= ROI.x & ...
                                trialData(:,1) <= ROI.x + ROI.w & ...
                                trialData(:,2) >= ROI.y & ...
                                trialData(:,2) <= ROI.y + ROI.h;

                faceData = trialData(faceDataIndex,:);
                faceTime = size(faceData,1) * msPerSample;
                %Extract from the whole face ROI the amount of time spent looking
                %at the sub ROIs (eyes, nose, mouth)

                % EYES
                eyesDataIndex = faceData(:,1) >= ROI.eyes.x & ...
                                faceData(:,1) <= ROI.eyes.x + ROI.eyes.w & ...
                                faceData(:,2) >= ROI.eyes.y & ...
                                faceData(:,2) <= ROI.eyes.y + ROI.eyes.h; 

                eyesData = faceData(eyesDataIndex,:);
                eyesTime = size(eyesData,1) * msPerSample;

                % NOSE
                noseDataIndex = faceData(:,1) >= ROI.nose.x & ...
                                faceData(:,1) <= ROI.nose.x + ROI.nose.w & ...
                                faceData(:,2) >= ROI.nose.y & ...
                                faceData(:,2) <= ROI.nose.y + ROI.nose.h; 

                noseData =  faceData(noseDataIndex,:);
                noseTime = size(noseData,1)* msPerSample;

                % MOUTH
                mouthDataIndex = faceData(:,1) >= ROI.mouth.x & ...
                                 faceData(:,1) <= ROI.mouth.x + ROI.mouth.w & ...
                                 faceData(:,2) >= ROI.mouth.y & ...
                                 faceData(:,2) <= ROI.mouth.y + ROI.mouth.h; 

                mouthData = faceData(mouthDataIndex,:);
                mouthTime = size(mouthData,1) * msPerSample;


                roiData = cat(1,roiData,[i xdatCode trialType ROIID faceTime eyesTime noseTime mouthTime]);

                
                end
                
            end
            
        end
       
    
    else
        disp(['XDAT code:',num2str(xdatCode),' is not present in XDATList'])
    end
    
    

end

results.roi = roiData;
results.fix = fixData;

end


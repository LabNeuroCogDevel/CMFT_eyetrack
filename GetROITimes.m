startCodes = [8];
targetCodes = [1:7,10:255];
endCodes=[9];
fixationCoords = [320,220];  % this is offset from true center [324,240] because the fixation image does not actually appear there (for some reason)



PP = ilabGetPlotParms;
ILAB = ilabGetIlAB;
data = PP.data;
correctedData = data;
trialIndex = PP.index;
fixationIndex = [];
driftCorrectionVectors = [];
driftCorrection = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD FACE ROI STRUCTURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subroi = struct('x',[],'y',[],'h',[],'w',[]);
faces = struct('faceID',[],'orientation',[],'eyes',subroi,'nose',subroi,'mouth',subroi);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN DRIFT CORRECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build a list of start and stop indices for the fixation trials and a list
% of the fixation correction vectors at from each fixation trial
for i=1:size(trialIndex,1)
    
    % index of the onset of the fixation cue
    targetIndex = trialIndex(i,3);
    % index of the end of the fixation trial
    endIndex = trialIndex(i,2);
    % index of the mid point in the fixation period
    middleIndex = targetIndex + floor((endIndex - targetIndex)/2);
    
    % Check to see if the trial is a fixation trial by examining the target
    % XDAT code.  If so, estimate the fixation point vector.  This will be
    % used to correct for fixation drift.  3 is the XDAT code for a
    % fixation period
    
    if data(targetIndex,3) == 3 
        
        fixationRange = data((targetIndex+50):endIndex,1:2);
        
        % Remove absurdly extreme X and Y values from the averaging computation
        fixationRange(fixationRange(:,1)>580) = NaN;
        fixationRange(fixationRange(:,1)<160) = NaN;
        fixationRange(fixationRange(:,2)>400) = NaN;
        fixationRange(fixationRange(:,2)<80) = NaN;

        
        % Winsorize the data before averaging
        for j = 1:size(fixationRange,2)
            fixationRange(:,j) = winsor(fixationRange(:,j),[30,60]);
        end
        
        % Get the average of the Winsorized X and Y coordinate during the
        % fixation range
     
        fixationRange = nanmean(fixationRange,1);
        
        driftCorrectionVectors = cat(1,driftCorrectionVectors,[middleIndex,fixationCoords - fixationRange]);
        
    end
  
end



% Create the correction for the sample points that precede the first
% fixation period.  Assume that initially no fixation drift has occurred.
IDX1 = 1;
IDX2 = driftCorrectionVectors(1,1);
CV1 = [0,0];
CV2 = driftCorrectionVectors(1,[2,3]);
length = IDX2-IDX1+1;
driftCorrection = vectorTimeWarp(CV1,CV2,length);
size(driftCorrection,1)
% Generate the corrections vectors for each time point of the raw data and
% concatenate it to the correction generated above.
for i=1:size(driftCorrectionVectors,1)-1
    size(driftCorrection,1)
    IDX1 = driftCorrectionVectors(i,1);
    IDX2 = driftCorrectionVectors(i+1,1);
    CV1 = driftCorrectionVectors(i,[2,3]);
    CV2 = driftCorrectionVectors(i+1,[2,3]);
    
    length = IDX2-IDX1;
    driftCorrection = cat(1,driftCorrection, vectorTimeWarp(CV1,CV2,length));
    
end

% Create the correction for the sample points that follow the last fixation
% period.  Assume that no fixation drift has occurred since the last
% fixation drift measurment and concatenate that correction vector to the
% end of the drift correction matrix
size(driftCorrection,1)
IDX1 = driftCorrectionVectors(size(driftCorrectionVectors,1),1);
IDX2 = size(data,1);
CV2 = driftCorrectionVectors(size(driftCorrectionVectors,1),[2,3]);
length= IDX2-IDX1;
tailCorrection = zeros(length,2);
tailCorrection(:,1) = CV2(1);
tailCorrection(:,2) = CV2(2);
driftCorrection = cat(1,driftCorrection,tailCorrection);

% Apply the correction to the data

correctedData(:,1) = correctedData(:,1) + driftCorrection(:,1);
correctedData(:,2) = correctedData(:,2) + driftCorrection(:,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END DRIFT CORRECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


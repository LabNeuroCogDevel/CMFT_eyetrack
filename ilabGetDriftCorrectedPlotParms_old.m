function [ outPP] = ilabGetDriftCorrectedPlotParms( fixationCoords, fixationXDAT, minFixSamples  )
% ILABGETDRIFTCORRECTEDPLOTPARMS
% Generates a replacement for the PLOTPARMS PP.data structure that corrects
% for linear drit in fixation.
PP = ilabGetPlotParms;
AP = ilabGetAnalysisParms;

outPP(2) = PP;
fixationIndex = [];
driftCorrectionVectors = [];
driftCorrection = [];
minValidSamplePoints = minFixSamples;
maxX = fixationCoords(1)+30;
minX = fixationCoords(1)-30;
maxY = fixationCoords(2)+30;
minY = fixationCoords(2)-30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN DRIFT CORRECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build a list of start and stop indices for the fixation trials and a list
% of the fixation correction vectors at from each fixation trial
for m=1:size(PP.index,1)
    
    % index of the onset of the fixation cue
    targetIndex = PP.index(m,3);
    % index of the end of the fixation trial
    endIndex = PP.index(m,2);
    % index of the mid point in the fixation period
    %middleIndex = targetIndex + floor((endIndex - targetIndex)/2);
    middleIndex = [];
    
    
    % Check to see if the trial is a fixation trial by examining the target
    % XDAT code.  If so, estimate the fixation point vector.  This will be
    % used to correct for fixation drift.
    
    if PP.data(targetIndex,3) == fixationXDAT
        disp('---------------------------------------')
        disp([' Trialnumber: ' num2str(m)])
        % Assume that the subject at the instant before the cue onset is
        % looking at fixation, but it is offset by some amount from true
        % fixation.
        
        % If the fixation period has a trial that follows it, get the index
        % of the
        
        % Start-----------------------------Fix-------------------End---------Start-----------------CueStart------------End
        %                                    |_________________________________________________________|
        %                                        |                               |________________|
        % Valid range of PP.data from which      |                                  |
        % to estimate fixation offset for________|                                  |
        % this trial                                                                |
        %                                                                           |
        %                                                                           |
        % The points samples closes to the                                          |
        % onset of the cue are the best                                             |
        % estimators of the fixation drift                                          |
        % for a trial.  Fixation carries over                                       |
        % into the first 1300 ms of a trial. So                                     |
        % the PP.data points we are interested in                                   |
        % extracting for our estimate are here:   __________________________________|
        
        
        if m < size(PP.index,1)
            
            maxIndex = PP.index(m+1,3);
            fixationRange = PP.data((targetIndex):maxIndex,1:2);
            validSamples = [];
            disp(['Number of samples in fix range: ' num2str(size(fixationRange,1))])
            disp(['Number of NaNs in fix range: ' num2str(sum(isnan(fixationRange(:,1))|isnan(fixationRange(:,2))))])
            disp(['Percent of bad samples: ' num2str(sum(isnan(fixationRange(:,1))|isnan(fixationRange(:,2)))/size(fixationRange,1))])
            % Work backwards and extract minFixSamples valid sample points.  Valid sample
            % point that will be used to estimate the fixation drift offset
            % will no non Nan entries whose instantaneous velocity is less than
            % some threshold value
            for n=size(fixationRange,1):-1:2
                
                if ~isnan(fixationRange(n,1)) && ~isnan(fixationRange(n,2))
                    
                    if fixationRange(n,1) <= maxX && fixationRange(n,1) >= minX && ...
                       fixationRange(n,2) <= maxY && fixationRange(n,2) >= minY
                        
                        x1 = fixationRange(n-1,1) - 320;
                        x2 = fixationRange(n,1) - 320;
                        y1 = fixationRange(n-1,2) - 240;
                        y2 = fixationRange(n,2) - 240;
                        
                        vx = atan(x1/AP.screen.distance) - atan(x2/AP.screen.distance);
                        vy = atan(y1/AP.screen.distance) - atan(y2/AP.screen.distance);
                        
                        v = sqrt(vx^2 + vy^2) * (180/pi);
                        
                        if v < AP.saccade.velThresh
                            validSamples = [validSamples; fixationRange(n,1:2)];
                        end
                    end
                    
                end
                
                % Exit loop if we have found the minimum number valid points
                if size(validSamples,1) == minValidSamplePoints
                    break
                end
                
            end
            
            if size(validSamples,1) >= minValidSamplePoints
                
                
                middleIndex = maxIndex - floor(n/2);
                
                disp(['Found enough valid samples after ' num2str(n) ' samples'] )
                
                % Estimate the fixation vector
                % Winsorize the PP.data before averaging
                for n = 1:size(validSamples,2)
                    validSamples(:,n) = winsor(validSamples(:,n),[20,80]);
                end
                
                % Get the average of the Winsorized X and Y coordinate during the
                % fixation range
                validSamples = nanmean(validSamples,1);
                
                disp(['Correction vector: ' num2str(fixationCoords - validSamples)])
                driftCorrectionVectors = cat(1,driftCorrectionVectors,[middleIndex,fixationCoords - validSamples]);
                
            else
                % Not enough valid sample points to estimate fixation correction
                
                middleIndex = maxIndex - floor(minValidSamplePoints/2);
                disp(['Did not find enough valid samples after ' num2str(n) ' samples'] )
                if size(driftCorrectionVectors,1) > 0
                    disp(['Using previous'])
                    % Use the previously calculated correction if one exisits
                    prevCorrection = driftCorrectionVectors(size(driftCorrectionVectors,1),:);
                    correction = [middleIndex,prevCorrection(1,2:3)];
                    driftCorrectionVectors = cat(1, driftCorrectionVectors,correction);
                    disp(['Using previous' num2str(prevCorrection)])
                else
                    disp(['Using [0 0]'])
                    % Do not apply a correction
                    driftCorrectionVectors = cat(1, driftCorrectionVectors, [middleIndex,0,0]);
                end
                
            end
            
        end
        
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

% Generate the corrections vectors for each time point of the raw PP.data and
% concatenate it to the correction generated above.
for m=1:size(driftCorrectionVectors,1)-1
    
    size(driftCorrection,1);
    IDX1 = driftCorrectionVectors(m,1);
    IDX2 = driftCorrectionVectors(m+1,1);
    CV1 = driftCorrectionVectors(m,[2,3]);
    CV2 = driftCorrectionVectors(m+1,[2,3]);
    length = IDX2-IDX1;
    driftCorrection = cat(1,driftCorrection, vectorTimeWarp(CV1,CV2,length));
    
end

% Create the correction for the sample points that follow the last fixation
% period.  Assume that no fixation drift has occurred since the last
% fixation drift measurment and concatenate that correction vector to the
% end of the drift correction matrix

IDX1 = driftCorrectionVectors(size(driftCorrectionVectors,1),1);
IDX2 = size(PP.data,1);
CV2 = driftCorrectionVectors(size(driftCorrectionVectors,1),[2,3]);
length= IDX2-IDX1;
tailCorrection = zeros(length,2);
tailCorrection(:,1) = CV2(1);
tailCorrection(:,2) = CV2(2);
driftCorrection = cat(1,driftCorrection,tailCorrection);


% Apply the correction to the PP.data
PP.data(:,1) = PP.data(:,1) + driftCorrection(:,1);
PP.data(:,2) = PP.data(:,2) + driftCorrection(:,2);

outPP(1) = PP;
end


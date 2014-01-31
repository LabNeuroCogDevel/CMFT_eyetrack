function  fixationList = ilabMkFixationList(data, idx, AP)
%
% Montez's modification of build in
% WF20140130: modified to take AP param. 
%    b/c I'm lazy AND will error if paths are wrong
%
%

% ILABMKFIXATIONLIST Calculates fixations
%    ILAB includes two types of fixation calculations: velocity and
%    dispersion based. In terms of the velocity algorithm, because eye
%    trackers typically acquire data at constant intervals the velocity
%    data is essentially equivalent to a distance measure. ILAB uses
%    distance because this is how the algorithm was originally set up.
%    The algorithm searches for point to point differences in vertical or
%    horizontal distance less than a chosen amount. Fixations also have
%    to meet a duration criteria. The velocity based method is very fast,
%    taking less than 1 second to calculate 100 fixations out of 12000
%    data points.
%
%    The dispersion algorithm is based on the article by Widdel, H. (1984).
%    Operational problems in analysing eye movements. In A. G. Gale & 
%    F. Johnson (Eds.), Theoretical and Applied Aspects of Eye Movement 
%    Research. North-Holland: Elsevier Science Publishers B.V.
%    In this case the algorithm initializes a window over the first n
%    points to cover the duration threshold. If the total dispersion (i.e.
%    for the combined horizontal + vertical directions ((max(H)-min(H)) + 
%    (max(V)-min(V))) is less or equal to the chosen threshold then points
%    are added to the fixation until the dispersion is greater than the
%    threshold. This algorithm also explicitly deals with missing data
%    points. In this case the user defines the maximum number of missing data
%    points to include in a fixation. A fixation is not terminated if the
%    duration of the missing data points is under this duration threshold.
%    If over the missing data duration threshold then the fixation is ended
%    before the missing data, and a new fixation search is started after the
%    missing data.
%
%    NOTE: This algorithm was modified in versions > 1.5 of
%    ilabMkFixationList. Previously the algorithm would move the fixation
%    window along the data stream and check if the dispersion was within
%    limits within the window only. It would then go back and examine over
%    all windows whether the dispersion came within limits. Unfortunately
%    this resulted in a loss of initial fixation points as the combined
%    window had to be collapsed to satisfy the dispersion limits. The
%    algorithm also computed x and y dispersions separately. However, this
%    could result in overall too much movement if both directions showed
%    movement just under the limits. The dispersion limits are now combined.
%
%    The dispersion based method is slower than the velocity method. It took  
%    13 seconds on the same 100 fixations out of 12000 data points.
%
%    Results of fixation analysis are stored in analysisParms.fix.list
%    Structure of analysisParms.fix.list array elements:
%    NOTE(!): Fixation Start and Fixation Duration are INDICES NOT TIMES.
%    Multiply by the Acquisition Interval to get the times.
%    fixationList = [trialnum xCtr yCtr xShiftDir dShift fixStartIndex fixDurationIndex pctInvalid];
% ___________________________________________________________________________

% Authors: Roger Ray, Darren Gitelman
% $Id: ilabMkFixationList.m 70 2010-06-07 00:23:51Z drg $


% Get some variables
% -----------------------------------------------------------------------------
%acqIntvl = ilabGetAcqIntvl;
acqIntvl = 1/60*100;

nTrials = size(idx,1);
fixationList = [];
k = 1;

% Get calculation type based variables
switch AP.fix.type
    case 'vel'
        hMax = AP.fix.params.vel.hMax;
        vMax = AP.fix.params.vel.vMax;
        mindur = AP.fix.params.vel.minDuration/acqIntvl;
    case 'disp'
        MaxDisp = AP.fix.params.disp.Disp;
        % rounding upwards mindur ensures that a fixation lasts at least this
        % long and avoids problems with mindur not being an integer if the
        % minimum duration time is not evenly divisible by the acqIntvl.
        mindur = ceil(AP.fix.params.disp.minDuration/acqIntvl);
        nandur = AP.fix.params.disp.NaNDur;
end

ilabProgressBar('clear');
ilabProgressBar('setup');

for n = 1:nTrials
         ilabProgressBar('update',100*n/nTrials,...
             ['Calculating Fixations for Trial ' num2str(n)]);
    drawnow
    trial = data(idx(n,1):idx(n,2),1:2);
    
    switch AP.fix.type
        case 'vel'
            % Velocity or Distance based calculation	
            ilabProgressBar('update',100*n/nTrials,...
                ['Calculating Fixations for Trial ' num2str(n)]);
            
            % Calculate the percentage of invalid data points
            iNaN=find(~isfinite(trial(:,1)));
            pctInvalid=(length(iNaN)/length(trial))*100;
            
            % Find indices of valid pts in trial buffer
            trialIdx = find(isfinite(trial(:,1)));
            
            % calc movement
            trialdiff = [diff(trial(trialIdx,1)) diff(trial(trialIdx,2))];
            
            if isempty(trialdiff)
                fix1 = [];
                fix2 = [];
                fixList = [];
            else
                % ISCAN Varies in calculating fixations by using < and not <= as in ILAB
                % ILAB uses <= as this is what the user asks for
                trialfix = find((abs(trialdiff(:,1)) <= hMax) &...
                    (abs(trialdiff(:,2)) <= vMax));
                
                % Make a vector the same length as current trial
                fixList = zeros(size(trial,1),1);
                % put ones at the points where coord shifts lie in fixation rectangle
                fixList(trialfix) = ones(size(trialfix,1),1);
                % diff will tell us points of transition from 0 to 1.
                trialdiff2 = [0; diff(fixList)];
                
                fix1 = find(trialdiff2 ==  1);       %  0 -> 1
                fix2 = find(trialdiff2 == -1);       %  1 -> 0
            end	
            if isempty(fix1) && isempty(fix2) % either all movement or all fixation
                if ~isempty(fixList) && (fixList(1) == 1)
                    fix1 = 0;
                    fix2 = length(fixList);
                else
                    fix1 = 0;
                    fix2 = 0;
                end
            elseif isempty(fix2) % starts with movement, ends with fixation
                fix2 = length(fixList);
                % starts with fixation, ends with movement
            elseif	isempty(fix1)
                fix1 = [1; fix1];
            elseif fix2(1) < fix1(1)
                if length(fix1) == length(fix2)
                    fix1(1) = fix2(1);
                elseif 	length(fix1) < length(fix2)
                    fix1 = [1; fix1];	
                end	
            end
            
            fixDuration = (fix2 - fix1)*acqIntvl + acqIntvl;
            fixIdx = find(fixDuration >= mindur);   % indices of fix > minDuration
            
            trial = trial(trialIdx,[1 2 4]); % add xdat here? [1 2 3] instead of 1:2
            
            %  Loop over all the fixations meeting min duration criterion
            %   and add an entry in the fixation list for each
            for j = 1:size(fixIdx,1)
                
                k = fixIdx(j);
                
                hpt = mean(trial(fix1(k):fix2(k),1));
                vpt = mean(trial(fix1(k):fix2(k),2));
                
                if j==1
                    lasthpt = hpt;
                    lastvpt = vpt;
                end			
                
                xShift = hpt - lasthpt;
                yShift = vpt - lastvpt;
                
                dShift = sqrt(abs((xShift)^2 + (yShift)^2));
                
                if xShift > 0
                    xShiftDir = 1;
                elseif xShift < 0
                    xShiftDir = -1;
                elseif xShift == 0
                    xShiftDir = 0;
                end
                
                lasthpt = hpt;
                lastvpt = vpt;
                
                fixDurIdx   = (fix2(k) - fix1(k)) + 1;
                fixStartIdx = fix1(k);
                
                fixationList = [fixationList; n hpt vpt xShiftDir dShift,...
                                fixStartIdx fixDurIdx pctInvalid];		
            end
        case 'disp'
            
            % 0 Center the X- and Y-coordinates
            centeredTrial = [trial(:,1)-720,trial(:,2)-450];
            [fixIndex,fixIndices] = GetFixations(centeredTrial,1038.75,6,1);
            
            %time = 0:size(centeredTrial,1)-1;
            %figure
            %plot(time',centeredTrial(:,1:2));
            %hold on
            %plot(time(fixIndex)',centeredTrial(fixIndex,:),'.r');
           
                    
            % assemble the fixation list
            % -------------------------------------------------------------
            % --
            %TOI=Trial Of Interest
            
            for o=1:size(fixIndices,1)
                
                indexRange = fixIndices(o,1):fixIndices(o,2);
                XdatCode = data(idx(n,3),3);

                                
                
                fixationList = [ ...
                                fixationList; ...
                                n,...
                                nanmean(trial(indexRange,1)),...
                                nanmean(trial(indexRange,2)),...
                                0,...
                                0,...
                                indexRange(1),...
                                (indexRange(end)-indexRange(1) + 1),...
                                0 ...
                                XdatCode ...
                            ];
                
            end

    end  % case
    
end % for n

ilabProgressBar('clear');

function [disp]=Dispersion(data)
    % This function takes an nx2 matrix of data and calculates it's
    % dispersion
    disph = max(data(:,1)) - min(data(:,1));
    dispv = max(data(:,2)) - min(data(:,2));
    disp  = 2*sqrt((disph/2)^2 + (dispv/2)^2);
return;

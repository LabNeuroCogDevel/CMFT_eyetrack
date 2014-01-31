function plotFixations( matfile )
% plotFixations plots each scored trial of CMTF 
%  faces are plotted as blocks given by an xls file
%  actual eye position data is plotted 
%  fixation and drifect corrected fixations are circles whos size varies by
%     fixation length
%
% function requires a mat files that has variables specified

    load(matfile)
    % fixtab is the fixation table, fixtab_nodrift is without drift correction
    % origPP has the eye position data
    % xdatlist is the xls ROI file as it was read when fixation scoring was run
    %
    
    % FIXATION TABLE is  
    %     n,.. trail number (132 of them)
    %     nanmean(trial(indexRange,1)),...average x
    %     nanmean(trial(indexRange,2)),... average y
    %     0,...
    %     0,...
    %     indexRange(1),... start
    %     (indexRange(end)-indexRange(1) + 1),... # samples
    %     0 ...
    %     XdatCode, .. -- end of "fixationList", start of TOIv
    %     condition,... (1..3)
    %     occurance of xdat (0...10)

    % XDATList is ROI_Final.xls organized into a structure

    %% initialize rois and positions
    r={'face','eyes','nose','mouth'};
    rcolor={'m','g','y','b'};
    p={'x','y','w','h'};
    allrects=zeros(length(xdatlist),6,length(r),4);

    % we have 3 for loops set up to extract the roi rectangles from 
    %   xdatlist -- the xls sheet of face region rectangles
    for i = 1:length(xdatlist); %for each of the 92 types
        %% setup figure
        %fig=figure;
        hold off;
        
        % draw image
        imagefile=fullfile( fileparts(which('plotFixations')), 'Screenshots', xdatlist(i).img );
        if(exist(imagefile,'file')); 
            imagesc(imresize( imread(imagefile),[480 640] ) );
        else
            close
            warning(['no screenshot: ' imagefile '\n'])
            figure
        end;
        axis equal;
        axis([0 640 0 460]) %  fix is center: [320,230] 
        hold on;
        

        %% draw all the rois
        for f=1:6; % for each face
            for ri=1:length(r); % for each region      
                for pi=1:length(p) 
                    allrects(i,f,ri,pi)=xdatlist(i).([p{pi} num2str(f)]).(r{ri});
                end
                rect=reshape(allrects(i,f,ri,:),[1 4]);
                % skip if there are NaNs
                if(any(isnan(rect))); continue; end

                rectangle('Position',rect,...
                          'Edgecolor',rcolor{ri});
            end
        end

        %% find all the fixations for this trial
        % uniquely I.D.ed by XDAT condition and (xdat) occurance

        fixidxs = ...
            find(xdatlist(i).XDAT == fixtab(:,9) & ...
             xdatlist(i).condition == fixtab(:,10) & ...
             xdatlist(i).occurance == fixtab(:,11) ...
         );

        fixidxs_nodrift = ...
            find(xdatlist(i).XDAT == fixtab_nodrift(:,9) & ...
             xdatlist(i).condition == fixtab_nodrift(:,10) & ...
             xdatlist(i).occurance == fixtab_nodrift(:,11) ...
         );


        %% what trial (in eye lab) is this
        % sanity check -- drift and nodrift should report the same trial
        if(unique(fixtab(fixidxs,1))~=unique(fixtab_nodrift(fixidxs_nodrift,1)))
            error('drift corrected and uncorrected are on different trials! how??!\n');
        end

        ilabtrial=unique(fixtab(fixidxs,1));

        %% get actual and calculated data
        eyedata  = origPP.data(origPP.index(ilabtrial,1):origPP.index(ilabtrial,2),1:2); 
        calcRoiFixIdx = cell2mat(data.fix(:,1))==ilabtrial;



        %% show points and paths
        % show fixation n,x,y, and size
        fprintf('fixation n,x,y, and s     .... ')
        fixtab(fixidxs,[1:3,7])
        % show the rectangles we are drawing
        fprintf('rectanges x,y,w,h         .... ')
        rects=reshape(allrects(1,:,:,:),[24 4]);
        rects(~isnan(rects(:,1)),:)
        % show how this was scored
        fprintf('scored fixation          .... ')
        data.fix(calcRoiFixIdx,:)

        % plot the drift correct fixation points
        scatter(fixtab(fixidxs,2),fixtab(fixidxs,3),fixtab(fixidxs,7),'fill','b')
        % plot the actual eye location
        plot(eyedata(:,1),eyedata(:,2),'c');
        % plot actual fixation
        scatter(fixtab_nodrift(fixidxs_nodrift,2),fixtab_nodrift(fixidxs_nodrift,3),fixtab_nodrift(fixidxs_nodrift,7),'fill','c')

        
        % plot bar chart of time in each ROI
        % from drift corrected data.roi -- i xdatCode trialType condition ROInum times.face times.eyes times.nose times.mouth
        % so 1:#r + 5 is the time in region
        % 100+r# is where on the x to plot
        %
        % we want each bar to be colored the same as the rectangle around
        % the region
        DRIdxBool = data.roi(:,1)==ilabtrial;
        if(any(DRIdxBool))
            for baridx=1:length(r)
              bar(100+baridx*100, sum(data.roi(DRIdxBool,baridx+5))/10 ,rcolor{baridx},'BarWidth',50 )
            end
        else
            warning(['no fixations for ' num2str(i) '\n']);
        end
        
        % give the plot some info
        title([ subjectID ' :: trial: ' num2str(i) ' # ' num2str(ilabtrial) ... 
                ' XDAT ' num2str(xdatlist(i).XDAT) ...
                ' cond ' num2str(xdatlist(i).condition) ...
                ' occur ' num2str(xdatlist(i).occurance) ]);

        % mark dot and lines, color of regions (r)
        legend({'fix_{corrected}','data_{actual}','fix_{actual}', r{:} })

        
        input('enter to go to next...','s')
        %close % turn hold off at begin of for loop instead
    end
   close
end


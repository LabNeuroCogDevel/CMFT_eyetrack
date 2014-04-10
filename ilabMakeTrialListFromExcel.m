function [ trials ] = ilabMakeTrialListFromExcel( path, sheetname,varargin )
% write list of modified rois
% we dont want to do this every time
if(~isempty(varargin))
    writeout=1;
    roifid=fopen('ROImatout.txt','w');
    % trial,XDAT,trialtype(1/2), condition, occurance, face# (j),roitype(1=face...4=mouth), x, y, w, h 
    fprintf(roifid,'% 6s\t',char({'trial','XDAT','ttype  ',...
                                  'cond', 'occur', 'face#',...
                                  'roi#', 'x', 'y', 'w', 'h'})');
    fprintf(roifid,'\n');


else
    writeout=0;
end
% Creates a list of trial XDAT codes and the ROIs associated with them from
% an excel sheet

%%%%%%
% XDAT,Picture,CONDITION,TRIALTYPE,OCCURANCE,"X (Upper Left)_1","Y(Upper Left)_1",Width_1,Height_1,"Eyes X_1","Eyes Y_1","Eyes W_1","Eyes H_1","Nose X_1","Nose Y_1","Nose W_1","Nose H_1","Mouth X_1","Mouth Y_1","Mouth W_1","Mouth H_1","X (Upper Left)_2","Y (Upper Left)_2",Width_2,Height_2,"Eyes X_2","Eyes Y_2","Eyes W_2","Eyes H_2","Nose X_2","Nose Y_2","Nose W_2","Nose H_2","Mouth X_2","Mouth Y_2","Mouth W_2","Mouth H_2","X (Upper Left)_3","Y (Upper Left)_3",Width_3,Height_3,"Eyes X_3","Eyes Y_3","Eyes W_3","Eyes H_3","Nose X_3","Nose Y_3","Nose W_3","Nose H_3","Mouth X_3","Mouth Y_3","Mouth W_3","Mouth H_3","X (Upper Left)_4","Y (Upper Left)_4",Width_4,Height_4,"Eyes X_4","Eyes Y_4","Eyes W_4","Eyes H_4","Nose X_4","Nose Y_4","Nose W_4","Nose H_4","Mouth X_4","Mouth Y_4","Mouth W_4","Mouth H_4","X (Upper Left)_5","Y (Upper Left)_5",Width_5,Height_5,"Eyes X_5","Eyes Y_5","Eyes W_5","Eyes H_5","Nose X_5","Nose Y_5","Nose W_5","Nose H_5","Mouth X_5","Mouth Y_5","Mouth W_5","Mouth H_5","X (Upper Left)_6","Y (Upper Left)_6",Width_6,Height_6,"Eyes X_6","Eyes Y_6","Eyes W_6","Eyes H_6","Nose X_6","Nose Y_6","Nose W_6","Nose H_6","Mouth X_6","Mouth Y_6","Mouth W_6","Mouth H_6"
%


[num txt, raw] = xlsread(path,sheetname);

faceasmat=zeros(30,11);




for i=2:size(raw,1) % each trial
    
    trials(i-1).XDAT = raw{i,1};
    trials(i-1).img  = raw{i,2};
    trials(i-1).condition = raw{i,3};
    trials(i-1).occurance = raw{i,5};
    trials(i-1).trialtype = raw{i,4};
    
    for j=0:5 % 6 possible people on the screen
        xlsidx=6; % roi positions start 6 columns into the file
        for roi={'face','eyes','nose','mouth'}
            for pos={'x','y','w','h'}
                p=raw{i,j*16+xlsidx}; % 16 is 4 rois * 4 postions

                %%%%
                % some ROIs were annotated from screenshots taken at
                %  1024x768 (?) -- convert to match actual faces
                %  another set were taken at 
                % finally presentaiton is 1140 x 900, asl+ilab  eye pos is 640x480
                
                %if(trials(i-1).condition > 1) % condition is not recoreded correctly?
                if((i-1)<38) % everything before 38 came from one set of screenshots (codtion 1)
                             % everything after was annotated with another
                    origxscale=1152;
                    origyscale=864;
                    fudge=8;
                else
                    origxscale=1024;
                    origyscale=768;
                    fudge=33;
                end
                
                switch pos{1}
                    case 'x'
                        p=((1440/2)-(((640/2)-p)*(origxscale/640)))*(640/1440);
                    case 'y'
                        p=(((900/2)-(((480/2)-p)*(origyscale/460)))*(480/900))-fudge;
                    case 'w'
                        p=p.*(origxscale/1440);
                    case 'h'
                        p=p.*(origyscale/900);
                end
                
                % but go back to what we had originally if
                % these are the roi's jen editted
                if ( (i-1)==37 || (i-1)==68 )
                    if( any( pos{1} == 'wx' ) )
                      p=raw{i,j*16+xlsidx} * 640/1440;
                    else %yh
                      p=raw{i,j*16+xlsidx} * 480/900;
                    end
                end
                    
                    
                
                trials(i-1).([pos{1} num2str(j+1)]).(roi{1}) = p;
                xlsidx=xlsidx+1;
            end            

        end

        % still inside trial loop (i) and face loop (j)
        % check that the rois have no gap
        % -- print out the change so we can audit this
        noseYshouldBe = ...
          trials(i-1).(['y' num2str(j+1)]).eyes + ...
          trials(i-1).(['h' num2str(j+1)]).eyes   - 1;

        mouthYshouldBe = ...
          trials(i-1).(['y' num2str(j+1)]).nose + ...
          trials(i-1).(['h' num2str(j+1)]).nose   - 1;
      
        % skip if there was no face
        if ~isnan(noseYshouldBe)
            if trials(i-1).(['y' num2str(j+1)]).nose  ~= noseYshouldBe
              fprintf('nose not aligned with eye, y_n %f set to %f\n', ...
                trials(i-1).(['y' num2str(j+1)]).nose, noseYshouldBe);

              trials(i-1).(['y' num2str(j+1)]).nose = noseYshouldBe;
            end

            if trials(i-1).(['y' num2str(j+1)]).mouth ~= mouthYshouldBe
              fprintf('mouth not aligned with nose, y_m %f set to %f\n', ...
                trials(i-1).(['y' num2str(j+1)]).mouth, mouthYshouldBe);

               trials(i-1).(['y' num2str(j+1)]).mouth = mouthYshouldBe;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % lets write out what we are actually using, like
            % trial,XDAT,trialtype(1/2), condition, occurance, face# (j),roitype(1=face...4=mouth), x, y, w, h 
            if(writeout)
                facenum=0;
                for face = {'face','eyes','nose','mouth'}
                   face=face{1};
                   facenum=facenum+1;
                   faceasmat(i,:) = [
                      i-1, trials(i-1).XDAT, trials(i-1).trialtype, ...
                      trials(i-1).condition, trials(i-1).occurance, ...
                      j, facenum, ...
                      trials(i-1).(['x' num2str(j+1)]).(face), ...
                      trials(i-1).(['y' num2str(j+1)]).(face), ...
                      trials(i-1).(['w' num2str(j+1)]).(face), ...
                      trials(i-1).(['h' num2str(j+1)]).(face), ...
                  ];
                  fprintf(roifid,'%03.02f\t',faceasmat(i,:));
                  fprintf(roifid,'\n');
                end
            end
            
            
        end
    end
    

    
    trialROIs = [];
    
    
    
%     if isnumeric(raw{i,3}) 
%         trialROIs = raw{i,3};
%     else
%        trialNumText = regexpi(raw{i,3},',','split');
%        
%        for j=1:size(trialNumText,2)
%             trialROIs = cat(1,trialROIs,str2num(trialNumText{j}));
%        end
%        
%     end
%     
%      trials(i-1).ROIs = trialROIs
    
end

if(writeout)
  fclose(roifid);
end

end

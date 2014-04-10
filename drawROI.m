function drawROI(roinum)
    
    % load roi positions
    cd(fileparts(which('readROItxt')))
    rois=readROItxt('ROImatout.txt','ROI/imagelist.txt');
    roistruct=rois(roinum);
    
    % accessing structure names
    r={'face','eyes','nose','mouth'};
    rcolor={'m','g','y','b'};
    p={'x','y','w','h'};
    
    % 6 possible faces, 4 rois, 4 positions xywh
     allrects=ones(6,length(r),4);

    imagefile=fullfile( fileparts(which('drawROI')), 'Screenshots', roistruct.img );

    if(exist(imagefile,'file')) 
      
    end
    
    fig=figure();
    imagesc(imresize( imread(imagefile) ,[480 640] ) );
    hold on;
    axis equal;
    axis([0 640 0 460]) %  fix is center: [320,230] 
    %set(gca,'YDir','reverse')
        
    moveboxes=cell(6,length(r));
    %% draw all the rois
    for f=1:6; % for each face
        for ri=1:length(r); % for each region      
            for pi=1:length(p) 
                thisroi = roistruct.([p{pi} num2str(f)]);
                if( isempty(thisroi) ); 
                  allrects(f,ri,pi)=1;
                else
                  allrects(f,ri,pi)=thisroi.(r{ri});
                end
            end
            rect=reshape(allrects(f,ri,:),[1 4]);
            % skip if there are NaNs
            if(any(isnan(rect))); continue; end
            h=imrect(gca,rect); 
            setColor(h,rcolor{ri});
            moveboxes{f,ri}=h;

        end
    end
    
    
    title([' Num  ' num2str(roinum) ...
           ' XDAT ' num2str(roistruct.XDAT) ...
           ' cond ' num2str(roistruct.condition) ...
           ' occur ' num2str(roistruct.occurance) ]);
       
       
    wh = warndlg('Please close this dialog once you are done adjusting your rectangle');
    uiwait(wh)
    
    for f=1:6;
        for ri=1:length(r);
            pos = getPosition(moveboxes{f,ri});
     
            if isempty(pos) || sum(pos)==4, continue,end
            
            rois(roinum).(['x' num2str(f)]).(r{ri}) = pos(1);
            rois(roinum).(['y' num2str(f)]).(r{ri}) = pos(2);
            rois(roinum).(['w' num2str(f)]).(r{ri}) = pos(3);
            rois(roinum).(['h' num2str(f)]).(r{ri}) = pos(4);
            fprintf('set face %d region %d: ', f,ri);
            fprintf('%f ',pos);
            fprintf('\n');
        end;
    end
    
    
    %% save new list
    roifid=fopen('ROImatout.txt','w');
    % trial,XDAT,trialtype(1/2), condition, occurance, face# (j),roitype(1=face...4=mouth), x, y, w, h 
    fprintf(roifid,'% 6s\t',char({'trial','XDAT','ttype  ',...
                                  'cond', 'occur', 'face#',...
                                  'roi#', 'x', 'y', 'w', 'h'})');
    fprintf(roifid,'\n');
    
    for i=1:length(rois)
        for j=0:5 % 6 possible people on the screen 

            if isempty(rois(i).(['x' num2str(j+1)])); continue;  end
            facenum=0;
            for face = {'face','eyes','nose','mouth'}
                  face=face{1};
                  facenum=facenum+1;

                  fprintf(roifid,'%d\t', [ ...
                      i, rois(i).XDAT, rois(i).trialtype, ...
                      rois(i).condition, rois(i).occurance, ...
                      j, facenum]);
                  fprintf(roifid,'%03.01f\t',[...
                      rois(i).(['x' num2str(j+1)]).(face), ...
                      rois(i).(['y' num2str(j+1)]).(face), ...
                      rois(i).(['w' num2str(j+1)]).(face), ...
                      rois(i).(['h' num2str(j+1)]).(face), ...
                    ]);
                  fprintf(roifid,'\n');
            end
        end
    end
    
    fclose(roifid);
    close(fig)

end

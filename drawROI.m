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
    hold on;
    axis equal;
    axis([0 640 0 460]) %  fix is center: [320,230] 
    set(gca,'YDir','reverse')
    
    if(exist(imagefile,'file')) 
      imagesc(imresize( imread(imagefile) ,[480 640] ) );
    end

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
            rectangle('Position',rect,...
                      'Edgecolor',rcolor{ri});

        end
    end
    
    title([' Num  ' num2str(roinum) ...
           ' XDAT ' num2str(roistruct.XDAT) ...
           ' cond ' num2str(roistruct.condition) ...
           ' occur ' num2str(roistruct.occurance) ]);
end
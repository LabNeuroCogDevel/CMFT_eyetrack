function [ trials ] = ilabMakeTrialListFromExcel( path, sheetname )
% Creates a list of trial XDAT codes and the ROIs associated with them from
% an excel sheet

%%%%%%
% XDAT,Picture,CONDITION,TRIALTYPE,OCCURANCE,"X (Upper Left)_1","Y(Upper Left)_1",Width_1,Height_1,"Eyes X_1","Eyes Y_1","Eyes W_1","Eyes H_1","Nose X_1","Nose Y_1","Nose W_1","Nose H_1","Mouth X_1","Mouth Y_1","Mouth W_1","Mouth H_1","X (Upper Left)_2","Y (Upper Left)_2",Width_2,Height_2,"Eyes X_2","Eyes Y_2","Eyes W_2","Eyes H_2","Nose X_2","Nose Y_2","Nose W_2","Nose H_2","Mouth X_2","Mouth Y_2","Mouth W_2","Mouth H_2","X (Upper Left)_3","Y (Upper Left)_3",Width_3,Height_3,"Eyes X_3","Eyes Y_3","Eyes W_3","Eyes H_3","Nose X_3","Nose Y_3","Nose W_3","Nose H_3","Mouth X_3","Mouth Y_3","Mouth W_3","Mouth H_3","X (Upper Left)_4","Y (Upper Left)_4",Width_4,Height_4,"Eyes X_4","Eyes Y_4","Eyes W_4","Eyes H_4","Nose X_4","Nose Y_4","Nose W_4","Nose H_4","Mouth X_4","Mouth Y_4","Mouth W_4","Mouth H_4","X (Upper Left)_5","Y (Upper Left)_5",Width_5,Height_5,"Eyes X_5","Eyes Y_5","Eyes W_5","Eyes H_5","Nose X_5","Nose Y_5","Nose W_5","Nose H_5","Mouth X_5","Mouth Y_5","Mouth W_5","Mouth H_5","X (Upper Left)_6","Y (Upper Left)_6",Width_6,Height_6,"Eyes X_6","Eyes Y_6","Eyes W_6","Eyes H_6","Nose X_6","Nose Y_6","Nose W_6","Nose H_6","Mouth X_6","Mouth Y_6","Mouth W_6","Mouth H_6"
%


[num txt, raw] = xlsread(path,sheetname);


for i=2:size(raw,1)
    
    trials(i-1).XDAT = raw{i,1};
    trials(i-1).img  = raw{i,2};
    trials(i-1).condition = raw{i,3};
    trials(i-1).occurance = raw{i,5};
    trials(i-1).trialtype = raw{i,4};
    
    for j=0:5
        
        trials(i-1).(['x' num2str(j+1)]).face = raw{i,j*16+6};
        trials(i-1).(['y' num2str(j+1)]).face = raw{i,j*16+7};
        trials(i-1).(['w' num2str(j+1)]).face = raw{i,j*16+8};
        trials(i-1).(['h' num2str(j+1)]).face = raw{i,j*16+9};
        
        trials(i-1).(['x' num2str(j+1)]).eyes = raw{i,j*16+10};
        trials(i-1).(['y' num2str(j+1)]).eyes = raw{i,j*16+11};
        trials(i-1).(['w' num2str(j+1)]).eyes = raw{i,j*16+12};
        trials(i-1).(['h' num2str(j+1)]).eyes = raw{i,j*16+13};
        
        trials(i-1).(['x' num2str(j+1)]).nose = raw{i,j*16+14};
        trials(i-1).(['y' num2str(j+1)]).nose = raw{i,j*16+15};
        trials(i-1).(['w' num2str(j+1)]).nose = raw{i,j*16+16};
        trials(i-1).(['h' num2str(j+1)]).nose = raw{i,j*16+17};
        
        trials(i-1).(['x' num2str(j+1)]).mouth = raw{i,j*16+18};
        trials(i-1).(['y' num2str(j+1)]).mouth = raw{i,j*16+19};
        trials(i-1).(['w' num2str(j+1)]).mouth = raw{i,j*16+20};
        trials(i-1).(['h' num2str(j+1)]).mouth = raw{i,j*16+21};
        
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



end

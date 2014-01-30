function [ trials ] = ilabMakeTrialListFromExcel( path, sheetname )
% Creates a list of trial XDAT codes and the ROIs associated with them from
% an excel sheet

[num txt, raw] = xlsread(path,sheetname);


for i=2:size(raw,1)
    
    trials(i-1).XDAT = raw{i,1};
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

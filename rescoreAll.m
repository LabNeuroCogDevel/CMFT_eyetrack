%% rescore everyone and write an excel sheet
%% add java librarys
addpath('excel_template') % and xlwrite
poidir='excel_template/poi_library/';
d=dir(poidir);
for di=1:length(d);
    if(all(d(di).name((end-2)=='jar'))); 
        javaaddpath([poidir d(di).name ]);
    end
end

%% add path to xlwrite
addpath('excel_template')

%% to score everyone in subj_eyemats (puts rescored in 'rescored/'
a=dir('subj_eyemats'); 
for i=1:length(a);  
 if(length(a(i).name)>4 && all(a(i).name( (end-2):end ) == 'mat' )); 
  fprintf('starting: %s\n',a(i).name); 
  % use saved origPP to rescore
  scored = rescorethisdataCMFT([ 'subj_eyemats/' a(i).name]);
  % add to excel
  success = writeToTemplate( scored, a(i).name(1:(end-4) ), 'excel_template/Fixation&ROI_template.xlsx');  
 end;
end
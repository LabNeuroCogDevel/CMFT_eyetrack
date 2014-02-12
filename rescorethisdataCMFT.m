
%% WF 20140210 -- rescore subjmat files
%% add java librarys
% d=dir('excel_template//poi_library'); for di=1:length(d); if(all(d(di).name((end-2)=='jar'))); javaaddpath(['excel_template/poi_library/' d(di).name ]), end; end

%% to score everyone in subj_eyemats (puts rescored in 'rescored/'
% a=dir('subj_eyemats'); for i=1:length(a);  
%  if(length(a(i).name)>4 && all(a(i).name( (end-2):end ) == 'mat' )); 
%   fprintf('starting: %s\n',a(i).name); 
%   rescorethisdataCMFT([ 'subj_eyemats/' a(i).name]);
%   fprintf('done: %s\n',a(i).name); 
%  end;
% end
%
function sub = rescorethisdataCMFT(varargin)
    if(length(varargin)==1)
        matfile=varargin{1};
    else 
        subjectID=input('subjectID: ','s');
        matfile = [ 'subj_eyemats/' subjectID '_drift.mat'];
    end
    
    sub = load(matfile);


    [sub.data,sub.xdatlist,sub.fixtab, sub.driftvector] = ilabExtractTrialData(sub.AP,sub.origPP,true);
    [sub.data_nodrift,~,sub.fixtab_nodrift,~] = ilabExtractTrialData(sub.AP,sub.origPP,false);
   
    [path, oldname, ext] =fileparts(matfile);
    newmatfile = ['rescored/' oldname ext];
    save(newmatfile ,'-struct','sub');


   %% show counts
   [a,b]=unique(sort(sub.data.fix(:,7)));
   s =[ b(2:end); length(sub.data.fix)];
   for i=1:length(s); fprintf('% 5s % 5i\n',a{i},s(i) ), end

   %% show fix
   fprintf('drift mean: % 3.3f % 3.3f\ndrift  std: % 3.3f % 3.3f\n',mean(sub.driftvector),std(sub.driftvector));
   
   %% code to show fixations
   fprintf('plotFixations(''%s''); % see eye movments overlayed on image and roi\n', newmatfile);




    %in lue of above try:
    % cd('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award/Behavioral Tasks/CMFT_EYE_SCRIPTS/')
    % andrew looked at the mouth the  whole time
    % load('example/andrew_drift_orig.mat'); 
    % addpath(genpath('/mnt/B/bea_res/Personal/Andrew/Autism/Experiments & Data/K Award Preparation/TASKS IN USE/FACES_ROI_INFO/Kirsten_Faces_ILab/ilab-3.6.8/' ) )
    % addpath(genpath(pwd))
    % [data, xdatlist,fixtab] = ilabExtractTrialData(AP, origPP,true);
    % [data_nodrift,~,fixtab_nodrift] = ilabExtractTrialData(AP,origPP,false);
    % 
end
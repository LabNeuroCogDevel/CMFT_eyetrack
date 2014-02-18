function rescoreAll(varargin)
    %%  get file list
    if(length(varargin)<1)
        filelist=dir('subj_eyemats');
    else
        filelist=varargin{1};
    end
    
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
     
    for i=1:length(filelist);  
     if(  length(filelist(i).name)>4 && ...
          all(filelist(i).name( (end-2):end ) == 'mat' ) ...
      )
      fprintf('starting: %s\n',filelist(i).name); 
      % use saved origPP to rescore
      scored = rescorethisdataCMFT([ 'subj_eyemats/' filelist(i).name]);
      % add to excel
      writeToTemplate( scored.data, filelist(i).name(1:(end-4) ), 'excel_template/Fixation&ROI_template.xlsx');  
      writeToTemplate( scored.data_nodrift, [ filelist(i).name(1:(end-4)), 'nodrift' ] , 'excel_template/Fixation&ROI_template.xlsx');  

     end;
    end
end
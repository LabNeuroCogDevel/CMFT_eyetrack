function [ROIList] = ilabMakeROIsFromExcelFile(path, sheetname)
%ilabMakeROIsFromExcelFile Creates a structure of ROIs to be used for data
%extraction for Kirsten's faces task


[num txt, raw] = xlsread(path,sheetname);

for i=1:size(num,1)
    
    ROIs(i).desc = 'No desc.';
    ROIs(i).ROIID = num(i,1);
    ROIs(i).x = num(i,2);
    ROIs(i).y = num(i,3);
    ROIs(i).h = num(i,4);
    ROIs(i).w = num(i,5);
    ROIs(i).eyes.x = num(i,6);
    ROIs(i).eyes.y = num(i,7);
    ROIs(i).eyes.h = num(i,8);
    ROIs(i).eyes.w = num(i,9);
    ROIs(i).nose.x = num(i,10);
    ROIs(i).nose.y = num(i,11);
    ROIs(i).nose.h = num(i,12);
    ROIs(i).nose.w = num(i,13);
    ROIs(i).mouth.x = num(i,14);
    ROIs(i).mouth.y = num(i,15);
    ROIs(i).mouth.h = num(i,16);
    ROIs(i).mouth.w = num(i,17);

end

ROIList = ROIs;

end

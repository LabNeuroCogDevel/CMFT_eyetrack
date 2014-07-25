function [ success ] = writeToTemplate( data, name, template, year )
  newxlsx=[ 'xls_' year '/' name '.xlsx'];
  fprintf('%s -- building excel\n',newxlsx); 
  copyfile(template,newxlsx )
  success(1) = xlwrite(newxlsx,data.roi,'results.roi','A5');
  success(2)  = xlwrite(newxlsx,data.fix,'results.fix','A5');

end


function [ success ] = writeToTemplate( scored, name, template )
  newxlsx=[ 'rescored/' name '.xlsx'];
  fprintf('%s -- building excel\n',newxlsx); 
  copyfile(template,newxlsx )
  success(1) = xlwrite(newxlsx,scored.data.roi,'results.roi','A5');
  success(2)  = xlwrite(newxlsx,scored.data.fix,'results.fix','A5');

end

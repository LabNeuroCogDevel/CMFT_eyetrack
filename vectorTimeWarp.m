function [ warpedVectors ] = vectorTimeWarp( v1, v2, length )
%VECTORTIMEWARP
%Takes as input two vectors, v1 and v2, start and end vectors and a scalar
%length value.  The output is a length x 2 matrix that represents the
%smooth transformation of v1 into v2 over length number of samples

weights = zeros(length,2);
xWarp = zeros(length,2);
yWarp = zeros(length,2);

weights(:,1) = 0:(1/(length-1)):1';
weights(:,2) = 1:(-1/(length-1)):0';

xWarp = v2(1).*weights(:,1) + v1(1).*weights(:,2);
yWarp = v2(2).*weights(:,1) + v1(2).*weights(:,2);

warpedVectors = cat(2,xWarp,yWarp);

end


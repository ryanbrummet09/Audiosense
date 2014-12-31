function [ scaledMatrix, minMaxV ] = scaleValues( ipMatrix, leftV, ...
                                        rightV, minMaxV )
%SCALEVALUES scales values of ipMatrix between leftV and rightV
%   Detailed explanation goes here
minMax = true;
if 3 == nargin
    minMaxV = [];
    minMax = false;
end
[r,c] = size(ipMatrix);
scaledMatrix = zeros(r,c);
for P=1:c
    toKeep = true(r,1);
    idx = find(isnan(ipMatrix(:,P)));
    toKeep(idx) = false;
    idx = find(isinf(ipMatrix(:,P)));
    toKeep(idx) = false;
    if ~minMax
        minV = min(ipMatrix(toKeep,P));
        maxV = max(ipMatrix(toKeep,P));
        minMaxV(P,1) = minV;
        minMaxV(P,2) = maxV;
    else
        minV = minMaxV(P,1);
        maxV = minMaxV(P,2);
    end
    scaledMatrix(toKeep,P) = ...
    (((ipMatrix(toKeep,P)-minV)/(maxV-minV))*(rightV-leftV))+leftV;
    scaledMatrix(~toKeep,P) = 0;
end
end


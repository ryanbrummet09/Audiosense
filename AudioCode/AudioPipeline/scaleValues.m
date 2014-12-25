function [ scaledMatrix ] = scaleValues( ipMatrix, leftV, rightV )
%SCALEVALUES scales values of ipMatrix between leftV and rightV
%   Detailed explanation goes here

[r,c] = size(ipMatrix);
scaledMatrix = zeros(r,c);
for P=1:c
    toKeep = true(r,1);
    idx = find(isnan(ipMatrix(:,P)));
    toKeep(idx) = false;
    idx = find(isinf(ipMatrix(:,P)));
    toKeep(idx) = false;
    minV = min(ipMatrix(toKeep,P));
    maxV = max(ipMatrix(toKeep,P));
    scaledMatrix(toKeep,P) = ...
    (((ipMatrix(toKeep,P)-minV)/(maxV-minV))*(rightV-leftV))+leftV;
    scaledMatrix(~toKeep,P) = 0;
end
end


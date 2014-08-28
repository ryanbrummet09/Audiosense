function [ subbands ] = getLogSubbands( fs, numberOfSubbands )
%GETLOGSUBBANDS calculate the log subbands
%   Input:
%           fs              :           sampling frequency
%           numberOfSubbands:           number of log subbands to create
% 
% 
%   Output:
%           subbands        :           frequency ranges
subbands = zeros(numberOfSubbands,2);
subbandsD = [];
for P=1:numberOfSubbands
    subbandsD(end+1) = power(2,P);
end
subbandsD(end+1) = 0;
for P=1:length(subbandsD)-1
    subbands(P,1) = fs/subbandsD(P);
    if 0 ~= subbandsD(P+1)
        subbands(P,2) = fs/subbandsD(P+1);
    else
        subbands(P,2) = 0;
    end
end
subbands = fliplr(flipud(subbands));
end


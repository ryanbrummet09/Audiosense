function [ dEncoding, dMapping ] = dummyEnc( inputArray )
%DUMMYENC dummy encodes values in a minimalistic sense
%   Detailed explanation goes here

uV = unique(inputArray);
uV = sort(uV);
n = length(uV);
dMapping = zeros(n,2);
for P=1:n
    dMapping(P,1) = uV(P,1);
    dMapping(P,2) = P;
end
m = length(inputArray);
for P=1:m
    inputArray(P) = dMapping(dMapping(:,1)==inputArray(P),2);
end
dEncoding = dummyvar(inputArray);
end


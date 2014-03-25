function [ cleanFile ] = preProcess(filename, reverseOrder)
%PREPROCESS Summary of this function goes here
%   Detailed explanation goes here

signal = getSoundData(filename);

if nargin == 2
    cleanFile = buzzBeepFilter(signal,reverseOrder);
else
    cleanFile = buzzBeepFilter(signal);
end

end


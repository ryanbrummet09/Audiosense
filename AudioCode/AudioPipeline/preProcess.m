function [ locs_buzz, locs_beep, signal, cleanFile ] = preProcess(filename, reverseOrder)
%PREPROCESS Summary of this function goes here
%   Detailed explanation goes here

signal = getSoundData(filename);

if nargin == 2
    [locs_buzz, locs_beep, cleanFile] = buzzBeepFilter(signal,reverseOrder);
else
    [locs_buzz, locs_beep, cleanFile] = buzzBeepFilter(signal);
end

end


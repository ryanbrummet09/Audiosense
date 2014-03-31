function [ locs_buzz, locs_beep, signal, cleanFile ] = preProcess(filename, reverseOrder)
%PREPROCESS Processes the signal by removing the beeps and buzzes
%   This function removes the beeps and buzzes from the sound file
%   specified as input. The output is of the following format:
%   [ location of buzzes, location of beeps, original signal, signal with
%   the beeps and buzzes removed]
%   A point to note here, the location of buzzes and beeps is in sample
%   number and NOT in time.
%   There is an input reverseOrder which reverses the way in which the file
%   is processed. If set to true, beeps are removed before buzzes.
%
%   See also, BUZZBEEPFILTER

signal = getSoundData(filename);

if nargin == 2
    [locs_buzz, locs_beep, cleanFile] = buzzBeepFilter(signal,reverseOrder);
else
    [locs_buzz, locs_beep, cleanFile] = buzzBeepFilter(signal);
end

end


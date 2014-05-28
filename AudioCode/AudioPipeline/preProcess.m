function [ locs_buzz, locs_beep, signal ] = preProcess(filename)
%PREPROCESS Processes the signal by removing the beeps and buzzes
%   This function removes the beeps and buzzes from the sound file
%   specified as input. The output is of the following format:
%   [ location of buzzes, location of beeps, original signal, signal with
%   the beeps and buzzes removed]
%   A point to note here, the location of buzzes and beeps is in sample
%   number and NOT in time.
%
%   See also, BUZZBEEPFILTER

signal = getSoundData(filename);
[locs_buzz, locs_beep] = buzzBeepFilter(signal);


end


function [ l_buzz,l_beep ] = buzzBeepFilter( signal )
%BUZZBEEPFILTER Removes the buzz and beep from the frame
%   BUZZBEEPFILTER Removes the buzz and beeps introduced in the audio due
%   to the haptic and sonus feedback mechanism of AudioSense. This filter
%   takes in the frame as input and returns a new frame with the buzzes and
%   the beeps removed as well as the locations of the buzzes and beeps. 
%
%   Input:
%           signal                  :       Input signal
%
%   Output:
%           l_buzz                  :       Location of buzzes
%           l_beep                  :       Location of beeps
%           signal                  :       original signal
%
%

[l_buzz,p1,f1] = remove_buzz(signal);
[l_beep,p2,f2] = remove_beeps(signal);
end


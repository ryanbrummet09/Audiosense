function [ subbandPower ] = logSubbandPower( data, fs, subbands )
%LOGSUBBANDPOWER calculate the logarithmic frequency subbands
%   Input:
%           data                :       the raw signal (frame)
%           fs                  :       sampling frequency
%           subbands            :       subbands to calculate
%                                       the power on
% 
%   Output:
%           subbandPower        :       subband power calculated from given
%                                       inputs
% 
% 
[r,c] = size(subbands);
subbandPower = zeros(1,r);
for P=1:r
    subbandPower(P) = bandpower(data,fs,[subbands(P,1), subbands(P,2)]);
end
end


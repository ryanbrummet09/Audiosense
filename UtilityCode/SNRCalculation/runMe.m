function [ snrV ] = runMe( filename, fs, frameSizeInSeconds )
%RUNME Calculate the SNR
%   Input:
%           filename        :       full path of file under consideration
%           fs              :       sampling frequency
%           frameSizeInSeconds :    size of frame to consider
% 
%   Output:
%           snrV            :       instanteneous SNR

f = fopen(filename, 'r');
data = fread(f, Inf, 'short', 0, 'l');
fclose(f);

scaledSignal = scaleSignal(data);
[~, scaledPower] = powerCalc(scaledSignal);
[snrV, ~] = instantSNR(scaledPower, fs, frameSizeInSeconds);

end


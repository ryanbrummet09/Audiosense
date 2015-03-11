function [ snrV, smoothedPower, noiseFloor ] = runMe( filename, fs, ...
                                    frameSizeInSeconds )
%RUNME Calculate the SNR
%   Input:
%           filename        :       full path of file under consideration
%           fs              :       sampling frequency
%           frameSizeInSeconds :    size of frame to consider
% 
%   Output:
%           snrV            :       instanteneous SNR
%           smoothedPower   :       estimated power in composite signal
%           noiseFloor      :       estimated power in noise floor

f = fopen(filename, 'r');
data = fread(f, Inf, 'short', 0, 'l');
fclose(f);

scaledSignal = scaleSignal(data);
[~, smoothedPower] = powerCalc(scaledSignal);
[snrV, noiseFloor] = instantSNR(smoothedPower, fs, frameSizeInSeconds);

end


function [ scaledSignal ] = scaleSignal( signalData, a, b, sigMin, sigMax )
%SCALESIGNAL Scale a signal
%   Scale the signal between [a,b], sigMin and sigMax are the min and max
%   values of the signal

if 1 == nargin
    a = -1;
    b = 1;
    sigMin = -32768;
    sigMax = 32767;
elseif 3 == nargin
    sigMin = -32768;
    sigMax = 32767;
end

scaledSignal = (((signalData - sigMin)/(sigMax-sigMin))*(b-a))+a;

end


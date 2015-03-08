function [ powerV, smoothedPower ] = powerCalc( signalData, N, a )
%POWERCALC Calculate the actual and smoothened power
%   Input:
%           signalData      :       input signal
%           N               :       number of samples for sliding window
%           a               :       constant for smoothening
% 
%   Output:
%           powerV          :       actual instanteneous power
%           smoothedPower   :       smoothened out instanteneous power

if 1 == nargin
    N = 128;
    a = 0.95;
elseif 2 == nargin
    a = 0.95;
end
powerV = zeros(size(signalData));
smoothedPower = zeros(size(signalData));
for P=1:length(signalData)
    if P <=N
        if 1 == P
            powerV(P) = signalData(P).^2;
            smoothedPower(P) = (1-a)*powerV(P);
        else
            powerV(P) = powerV(P-1) + signalData(P).^2;
            smoothedPower(P) = a*smoothedPower(P-1) + (1-a)*powerV(P);
        end
    else
        powerV(P) = powerV(P-1) + signalData(P)^2 - signalData(P-N)^2;
        smoothedPower(P) = a*smoothedPower(P-1) + (1-a)*powerV(P);
    end
end
end


function [ snrV, P_noise ] = instantSNR( smoothedPower, fs, ...
                                frameSizeInSeconds)
%INSTANTSNR calculate the instant SNR and noise floor
%   Input:
%           smoothedPower       :       smoothened power signal
%           fs                  :       sampling frequency
%           frameSizeInSeconds  :       size of frame to look at in seconds
%   
%   Output:
%           snrV                :       instanteneous SNR
%           P_noise             :       noise floor

if 1 == nargin
    fs = 16000;
    frameSizeInSeconds = 0.064;
elseif 2 == nargin
    frameSizeInSeconds = 0.064;
end
P_miniFrame_min = inf;
P_noise = zeros(size(smoothedPower));
snrV = P_noise;
samplesInFrame = fs*frameSizeInSeconds;
for P=1:length(smoothedPower)
    if 1 == mod(P, samplesInFrame)
        if length(smoothedPower) < (P+samplesInFrame-1)
            P_miniFrame_min = min(smoothedPower(P:length(smoothedPower)));
        else
            P_miniFrame_min = min(smoothedPower(P:P+samplesInFrame-1));
        end
    end
    P_noise(P) = min([smoothedPower(P), P_miniFrame_min]);
    snrV(P) = 10*log10((smoothedPower(P) - P_noise(P))/P_noise(P));
end
end


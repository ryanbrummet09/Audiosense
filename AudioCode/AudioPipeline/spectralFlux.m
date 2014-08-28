function [ flux ] = spectralFlux( freq, lastSpectralAmp, ...
    currentSpectralAmp)
%SPECTRALFLUX Calculate the spectral flux
%   Input:
%           freq                :       frequencies of the FFT
%           lastSpectralAmp     :       last frame's spectral amplitude
%           currentSpectralAmp  :       current frame's spectral amplitude
% 
%   Output:
%           flux                :       spectral flux
% 
% 
flux = 0;
for P=1:length(freq)
    flux = flux + (currentSpectralAmp(P) - lastSpectralAmp(P)).^2;
end
end


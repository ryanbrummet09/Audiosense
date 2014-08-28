function [ spectralCentroidV ] = spectralCentroid( freq, spectralAmp )
%SPECTRALCENTROID calculates the spectral centroid
%   Input:
%               freq            :           frequencies from fft
%               spectralAmp     :           amplitude associated with the
%                                           frequencies
% 
%   Output:
%               spectralCentroid:           calculated spectral centroid
% 
% 

spectralCentroidV = 0;
spectralAmp = abs(spectralAmp);
for P=1:length(freq)
    spectralCentroidV = spectralCentroidV + (spectralAmp(P).*freq(P));
end
spectralCentroidV = spectralCentroidV./sum(spectralAmp);
end


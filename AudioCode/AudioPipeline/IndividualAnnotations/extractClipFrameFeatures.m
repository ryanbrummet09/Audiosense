function [ featureVector, spectralAmp]= extractClipFrameFeatures(...
    data, f, mfccCoff, spectralRollOffLimits, subbands, ...
    lastFrameSpectralAmp)
%EXTRACTCLIPFRAMEFEATURES extracts features from the input frame
%   Input:
%           data                    :           input frame
%           f                       :           sampling frequency
%           mfccCoff                :           the number of mfcc
%                                               coefficients
%           spectralRollOffLimits   :           vector containing the
%                                               frequencies to determine
%                                               the rolloffs
%           lastFrameSpectralAmp    :           this is an optional input,
%                                               it represents the spectral
%                                               amplitude associated with
%                                               the last frame
%           subbands                :           the subbands to extract the
%                                               power from
% 
%   Output:
%           featureVector           :           this vector contains the
%                                               features,in the following
%                                               order: rms, zcr, mfcc
%                                               (number defined by
%                                               mfccCoff), spectral
%                                               rolloffs (number defined by
%                                               length of rolloff limits),
%                                               spectral flux, spectral
%                                               centroid, spectral entropy,
%                                               subband power (number
%                                               defined by the length of
%                                               subbands)
%         
% 
if 5 == nargin
    firstFrame = true;
    lastFrameSpectralAmp = [];
else
    firstFrame = false;
end
addpath ../;
addpath ../voicebox/;
featureVector = [];
%% FFT
[spectralAmp, freq] = getFFT(data,f);
spectralAmp = spectralAmp(ceil(end/2):end);
freq = freq(ceil(end/2):end);
%% get the temporal features
% root mean square of amplitude
featureVector(1,end+1) = rms(data);
% zero crossing rate
featureVector(1,end+1) = zcr(data);

%% get the spectral features

% mfcc
coff = melcepst(data,f,'Rt0z',mfccCoff,floor(3.*log(f)),length(data));
for P=1:length(coff)
    featureVector(1,end+1) = coff(P);
end
% rolloff
for P=1:length(spectralRollOffLimits)
    featureVector(1,end+1) = spectralRolloff(spectralAmp, freq, ...
        spectralRollOffLimits(P));
end
% flux
if firstFrame
    featureVector(1,end+1) = sum(spectralAmp.^2);
else
    featureVector(1,end+1) = spectralFlux(freq, lastFrameSpectralAmp, ...
    spectralAmp);
end
% centroid
featureVector(1,end+1) = spectralCentroid(freq, spectralAmp);
% entropy
featureVector(1,end+1) = entropy(spectralAmp);
% subband power
subbandPower = logSubbandPower(data,f,subbands);
for P=1:length(subbandPower)
    featureVector(1,end+1) = subbandPower(P);
end
end


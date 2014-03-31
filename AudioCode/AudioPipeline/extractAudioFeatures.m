function [ featureVector ] = extractAudioFeatures( window,fname,LEPercent,frequency,mfccCoff )
%EXTRACTAUDIOFEATURES Extracts the various features, for the window model
%   EXTRACTAUDIOFEATURES extracts a number of audio features from the input
%   window. Currently three types of features are extracted using
%   EXTRACTAUDIOFEATURES viz., demograhic, time domain, and frequency
%   domain.
%   The following demographic features are extracted:
%           - Patient ID, Condition ID, Session ID
%   For these, filename is taken as input.
%   The following time domain features are extracted:
%           - Zero Crossing Rate, Root Mean Squared Value, Low Energy
%           Percentage
%   For these, LEPercent and window are taken as inputs.
%   The following frequency domain features are extracted:
%           - Entropy, Spectral Rolloff, MFCC Cofficients
%   For these, window, frequency, number of MFCC are taken as input.
%
%   This returns a vector which is organized as follows:
%   [patient ID, condition ID, session ID, Low-Energy Percentage, Zero
%   Crossing Rate, Root Mean Squared Value, Entropy, Spectral Rolloff,
%   Mel-Frequency Cepstral Coefficients (13 in number)]
featureVector = [];
[patid,cid,sid] = getInfo(fname);
featureVector(end+1) = patid; 
featureVector(end+1) = cid; 
featureVector(end+1)= sid;
featureVector(end+1) = LEPercent;
featureVector(end+1) = zcr(window);
featureVector(end+1) = rms(window);
[specAmp,freq] = getFFT(window,frequency);
featureVector(end+1) = entropy(specAmp(ceil(end/2):end));
featureVector(end+1) = spectralRolloff(specAmp(ceil(end/2):end),freq(ceil(end/2):end));
c = melcepst(window,frequency,'Rt0z',mfccCoff,floor(3.*log(frequency)),length(window));
featureVector(end+1:end+length(c)) = c;
end


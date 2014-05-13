function [ featureVector ] = extractFrameFeatures( frame,fname,frequency,mfccCoff, LowEnergyIndicator, BuzzIndicator, BeepIndicator )
%EXTRACTFRAMEFEATURES Extracts the various features, for the window model
%   EXTRACTFRAMEFEATURES extracts a number of audio features from the input
%   frame. Currently three types of features are extracted using
%   EXTRACTFRAMEFEATURES viz., demograhic, time domain, and frequency
%   domain.
%   The following demographic features are extracted:
%           - Patient ID, Condition ID, Session ID
%   For these, filename is taken as input.
%   The following time domain features are extracted:
%           - Zero Crossing Rate, Root Mean Squared Value, Low Energy
%           Indicator, Buzz Indicator, Beep Indicator
%   For these, LowEnergyIndicator, Buzz Indicator, Beep Indicator, 
%   and window are taken as inputs.
%   The following frequency domain features are extracted:
%           - Entropy, Spectral Rolloff, MFCC Cofficients
%   For these, window, frequency, number of MFCC are taken as input.
%
%   This returns a vector which is organized as follows:
%   [patient ID, condition ID, session ID, Zero
%   Crossing Rate, Root Mean Squared Value, Entropy, Spectral Rolloff,
%   Mel-Frequency Cepstral Coefficients (13 in number), Low Energy
%   Indicator, Buzz Indicator, Beep Indicator]
featureVector = zeros(1,11+mfccCoff);
[patid,cid,sid] = getInfo(fname);
featureVector(1) = patid; 
featureVector(2) = cid; 
featureVector(3)= sid;
featureVector(4) = zcr(frame);
featureVector(5) = rms(frame);
[specAmp,freq] = getFFT(frame,frequency);
featureVector(6) = entropy(specAmp(ceil(end/2):end));
featureVector(7) = spectralRolloff(specAmp(ceil(end/2):end),freq(ceil(end/2):end));
c = melcepst(frame,frequency,'Rt0z',mfccCoff,floor(3.*log(frequency)),length(frame));
featureVector(8:7+length(c)) = c;
featureVector(7+length(c)+1) = LowEnergyIndicator;
featureVector(7+length(c)+2) = BuzzIndicator;
featureVector(7+length(c)+3) = BeepIndicator;

end


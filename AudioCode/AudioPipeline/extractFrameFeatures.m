function [ featureVector ] = extractFrameFeatures( frame,fname,frequency,mfccCoff, LowEnergyIndicator, BuzzIndicator, BeepIndicator )
%EXTRACTFRAMEFEATURES Summary of this function goes here
%   Detailed explanation goes here
featureVector = [];
[patid,cid,sid] = getInfo(fname);
featureVector(end+1) = patid; 
featureVector(end+1) = cid; 
featureVector(end+1)= sid;
featureVector(end+1) = zcr(frame);
featureVector(end+1) = rms(frame);
[specAmp,freq] = getFFT(frame,frequency);
featureVector(end+1) = entropy(specAmp(ceil(end/2):end));
featureVector(end+1) = spectralRolloff(specAmp(ceil(end/2):end),freq(ceil(end/2):end));
c = melcepst(frame,frequency,'Rt0z',mfccCoff,floor(3.*log(frequency)),length(frame));
featureVector(end+1:end+length(c)) = c;
featureVector(end+1) = LowEnergyIndicator;
featureVector(end+1) = BuzzIndicator;
featureVector(end+1) = BeepIndicator;

end


function [ featureVector ] = extractFeatures( window,fname,LEPercent,frequency,mfccCoff )
%EXTRACTFEATURES Summary of this function goes here
%   Detailed explanation goes here
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


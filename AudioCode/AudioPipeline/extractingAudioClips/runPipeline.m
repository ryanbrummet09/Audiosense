function runPipeline( fileList, fs, mfccCoff, srfLimits, ...
    frameSizeInSeconds, numberOfSubbands )
%RUNPIPELINE Summary of this function goes here
%   Detailed explanation goes here

%% add dependencies
addpath ../;
addpath ../voicebox/;

%% create parallel workers
parobject = parpool;
%% read audio file
n = length(fileList);
subbands = getLogSubbands(fs, numberOfSubbands);
parfor P=1:n
    fname = fileList{P};
    disp(fname);
    data = getSoundData(fname);
    [bz,bp,frames] = framing(data,fs,frameSizeInSeconds);
    [r,c] = size(frames);
    featureVector = [];
    lastSpectralAmp = [];
    for Q=1:r
        if 1 == Q
            [fv, lastSpectralAmp] =extractClipFrameFeatures(frames(Q,:),...
                fs, mfccCoff, srfLimits, subbands);
        else
            [fv, lastSpectralAmp] =extractClipFrameFeatures(frames(Q,:),...
                fs, mfccCoff, srfLimits, subbands, lastSpectralAmp);
        end
        featureVector(end+1,:) = fv;
    end
    toSaveFname = strsplit(fname,'/');
    toSaveFname = toSaveFname{end};
    toSaveFname = strsplit(toSaveFname,'.');
    toSaveFname = strcat('features/',toSaveFname{1});
    parSaveVariable(toSaveFname,featureVector);
end
%% close parallel workers
delete(parobject);
end


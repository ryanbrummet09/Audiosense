function runPipeline( fileList, fs, mfccCoff, srfLimits, ...
    frameSizeInSeconds, numberOfSubbands, wavFiles )
%RUNPIPELINE basic setup of the pipeline
%   This function creates the features for the annotated files.
%   Input:
%           fileList            :           List of files to consider
%           fs                  :           Sampling frequency
%           mfccCoff            :           number of mfcc coefficients
%                                           excluding the zeroth
%           srfLimits           :           vector containing the limits
%                                           for calculating the spectral
%                                           rolloffs, these have to be
%                                           between 0-1
%           frameSizeInSeconds  :           Size of the frame in seconds
%           numberOfSubbands    :           number of subbands to calculate
%                                           the log subband power
%           wavFiles            :           This is an optional flag to
%                                           indicate whether the input
%                                           files are wav files

%% add dependencies
addpath ../;
addpath ../voicebox/;

%% create parallel workers
parobject = parpool;
%% read audio file
n = length(fileList);
subbands = getLogSubbands(fs, numberOfSubbands);
if 6 == nargin
    wavFiles = false;
end
parfor P=1:n
    fname = fileList{P};
    disp(fname);
    if wavFiles
        data = getSoundData(fname,wavFiles);
    else
        data = getSoundData(fname);
    end
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
    if wavFiles
        toSaveFname = strcat('features_wav/',toSaveFname{1});
    else
        toSaveFname = strcat('features/',toSaveFname{1});
    end
    parSaveVariable(toSaveFname,featureVector);
end
%% close parallel workers
delete(parobject);
end


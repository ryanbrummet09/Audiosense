function runPipelinePhoneData( fileList, pids, cids, sids, labels, fs, ...
    mfccCoff, srfLimits, frameSizeInSeconds, numberOfSubbands, wavFiles)
%RUNPIPELINEPHONEDATA basic setup of the pipeline for phone data
%   This function creates the features for the annotated files.
%   Input:
%           fileList            :           List of files to consider
%           pids                :           List of patient IDs,
%                                           corresponding to the fileList
%           cids                :           List of condition IDs,
%                                           corresponding to the fileList
%           sids                :           List of session IDs,
%                                           corresponding to the fileList
%           labels              :           List of labels corresponding to
%                                           the fileList
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
if 10 == nargin
    wavFiles = false;
end
if wavFiles
    if 7 ~=exist(sprintf('featuresPhone_wav_%d',int32(frameSizeInSeconds*1000)))
        mkdir(sprintf('featuresPhone_wav_%d',int32(frameSizeInSeconds*1000)));
    end
else
    if 7~=exist(sprintf('featuresPhone_%d',int32(frameSizeInSeconds*1000)))
        mkdir(sprintf('featuresPhone_%d',int32(frameSizeInSeconds*1000)));
    end
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
    toSaveFname = sprintf('%d_%d_%d_%s',pids(P),cids(P),sids(P),...
        labels{P});
    if wavFiles
        toSaveFname = strcat(sprintf('featuresPhone_wav_%d/',int32(frameSizeInSeconds*1000)),toSaveFname);
    else
        toSaveFname = strcat(sprintf('featuresPhone_%d/',int32(frameSizeInSeconds*1000)),toSaveFname);
    end
    parSaveVariable(toSaveFname,featureVector);
end
%% close parallel workers
delete(parobject);
end


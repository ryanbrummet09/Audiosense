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
    if 7 ~=exist('featuresPhone_wav')
        mkdir('featuresPhone_wav');
    end
else
    if 7~=exist('featuresPhone')
        mkdir('featuresPhone');
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
    toLookInto = 90*16000;
    if toLookInto > length(data)
        toLookInto = length(data);
    end
    data = data(1:toLookInto);
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
    toSaveFname = sprintf('%d_%d_%d_1_%s',pids(P),cids(P),sids(P),...
        labels{P});
    if wavFiles
        toSaveFname = strcat('featuresPhone_wav/',toSaveFname);
    else
        toSaveFname = strcat('featuresPhone/',toSaveFname);
    end
    parSaveVariable(toSaveFname,featureVector);
end
%% close parallel workers
delete(parobject);
end


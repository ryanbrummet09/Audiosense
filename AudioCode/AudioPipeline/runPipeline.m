function [ featureVector ] = runPipeline(mfccCoff, frequency, fileList)
%RUNPIPELINE An example pipeline structure
% Input:
%           mfccCoff        :       Number of MFCCs excluding the 1st
%           frequency       :       Sampling frequency of the signal
%           fileList        :       Boolean indicating whether the input
%                                   would be in the form of a text file
%                                   (true) or would be manually selected by
%                                   the user (false/ no input)
% 
% Output:
%           featureVector   :       Feature vector where each row is a
%                                   different sample

%% Dependencies
% We begin with adding the dependencies:
% 1. voicebox - for entropy, mfcc etc.
% 2. preprocess - buzz and beep removal
addpath voicebox;
addpath preprocess;

% make sure that the presistent variables would work fine
mlock;

%% Defining input mode
% fileList is a boolean flag that indicates whether the input is in a text
% file form where each line is the path to an audio file or whether the
% user has to manually select the files from a folder
if nargin < 3
    fileList = false;
end

% depending on the value of fileList we obtain the input
if ~fileList
    [fname,pname] = uigetfile('*.audio','MultiSelect','on');
    fname = strcat(pname,fname);
else
    [fileWithList, fLPname] = uigetfile('*.txt');
    % get all the filenames with paths
    fname = importdata(strcat(fLPname,fileWithList));
end

%% Sanity check
% It has been noticed that, sometimes, we get files that are of zero
% length. We run our input through a "sanity check" in order to prune those
% files out. This also returns the number of rows we would need for the
% audio files. This helps in optimizing the code.

[fname,removedFiles, numberOfRows] = sanityCheck(fname,frequency,0.02);

%% Feature computation
% The gui waitbar indicates how much progress has been achieved
h = waitbar(0,'Initializing Calculations');
  featureVector = zeros(numberOfRows,23);

% The rmsThreshold is obtained from emperical studies, these can be checked
% out in the TestingAndValidation folder
rmsThreshold = 96.766923584390270; 
K = 1;
% For each file we calculate the features

for P=1:length(fname)        
    f = fname{P};
    tt = strsplit(f,'/');
    tt = tt{end};
%     obtain the locations of the buzzes and beeps
    try
        [locs_buzz, locs_beep, audioSignal] = preProcess(f);
    catch err
        errmsg = sprintf('Preprocessing error for file %s, skipping file',tt);
        disp(errmsg);
        err
        continue;
    end
%     frame the input audio and also get the buzz and beep masks. These
%     masks are binary arrays where entries are switched on if there are
%     any buzzes or beeps. The audio is also broken up into frames of 20ms
%     each. The windowing used is rectangular.
    try
        [buzzMask, beepMask, frames] = framing(audioSignal,frequency,0.02, locs_buzz, locs_beep);
    catch err
        errmsg = sprintf('Framing error for file %s, skipping file',tt);
        disp(errmsg);
        err
        continue;
    end
    LowEnergyMask = false(1,length(frames));
    
%     for each frame we calculate the features
    for Q=1:length(frames)
        s = sprintf('frame # %d of %d \n %s \n(file %d of %d)',Q,length(frames),tt,P,length(fname));
        waitbar(Q/length(frames),h,s);
        lastFrameOfFile = (frames(Q,:)==frames(end,:));
        
%         if there are buzzes or beeps in the frame, we drop them
        if buzzMask(Q) | beepMask(Q)
            % drop the frames with buzz or beep
            [ptid,cid,sid] = getInfo(fname{P});
            fv = zeros(1,11+mfccCoff);
            fv(1) = ptid; fv(2)=  cid; fv(3) = sid;
            fv(end-1) = buzzMask(Q);  fv(end) = beepMask(Q);
            
%             the feature vector is filled with blanks in this case
%             fv = updateFeatureVector(fv,false);
            featureVector(K,:) = fv;
            K = K+1;
            continue;
        end
        
%     we determine the low energy frames (no useful information/no voice
%     activity).
        try
            LowEnergyMask(Q) = frameProcessing(frames(Q,:),rmsThreshold);
%           The extracted features are stored in a feature matrix
            featureVector(K,:) = extractFrameFeatures(frames(Q,:),fname{P},frequency,mfccCoff,LowEnergyMask(Q),buzzMask(Q),beepMask(Q));
%           fv = extractFrameFeatures(frames(Q,:),fname{P},frequency,mfccCoff,LowEnergyMask(Q),buzzMask(Q),beepMask(Q));
%           fv = updateFeatureVector(fv,false);
            K = K+1;
        catch err
            errmsg = sprintf('Feature error for file %s in frame %d, skipping frame',tt,Q);
            disp(errmsg);
            err
            continue;
        end
    end
end
% unlock the memory of the persistent variables
munlock;
% featureVector = updateFeatureVector([],true);
end


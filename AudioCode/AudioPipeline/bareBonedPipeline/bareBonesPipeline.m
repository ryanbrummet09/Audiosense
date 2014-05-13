function bareBonesPipeline( mfccCoff, frequency, fileListName, runTag )
%BAREBONESPIPELINE A bare-boned implementation of the audio pipeline
% Input:
%           mfccCoff        :       Number of MFCCs excluding the 1st
%           frequency       :       Sampling frequency of the signal
%           fileList        :       Boolean indicating whether the input
%                                   would be in the form of a text file
%                                   (true) or would be manually selected by
%                                   the user (false/ no input)
% 
% Something to note here is that there is no output, the feature vector is
% stored as mat file. The main purpose of this function is not to return
% features for calculations, it is to compute the features and store them.

%% Dependencies
% We begin with adding the dependencies:
% 1. voicebox - for entropy, mfcc etc.
% 2. preprocess - buzz and beep removal
% 3. other stuff
addpath ../voicebox/;
addpath ../preprocess/;
addpath ../;


%% get the audio file names from the file containing them
fname = importdata(fileListName);


%% Sanity check
% It has been noticed that, sometimes, we get files that are of zero
% length. We run our input through a "sanity check" in order to prune those
% files out. This also returns the number of rows we would need for the
% audio files. This helps in optimizing the code.

[fname,removedFiles, numberOfRows] = sanityCheck(fname,frequency,0.02);

%% Feature computation
% we start out with a predetermined size feature vector
numberOfSamplesToStore = 500000;
featureVector = nan(numberOfSamplesToStore,11+mfccCoff);
R = 1;
varFnameTemplate = strcat('featureVector_',runTag,'_');

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
        if numberOfSamplesToStore < K
            varFname = strcat(varFnameTemplate,num2str(R));
            save(varFname,'featureVector');
            s = sprintf('Saved variable %s.mat',varFname);
            disp(s);
            featureVector = nan(numberOfSamplesToStore,11+mfccCoff);
            R = R+1;
            K=1;
        end
%         if there are buzzes or beeps in the frame, we drop them
        if buzzMask(Q) | beepMask(Q)
            % drop the frames with buzz or beep
            [ptid,cid,sid] = getInfo(fname{P});
            fv = [];
            fv(1,end+1) = ptid; fv(1,end+1)=  cid; fv(1,end+1) = sid;
            fv(1,end+1:end+18) = 0;
            fv(1,end+1) = buzzMask(Q);  fv(1,end+1) = beepMask(Q);
            
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
            K = K+1;
        catch err
            errmsg = sprintf('Feature error for file %s in frame %d, skipping frame',tt,Q);
            disp(errmsg);
            err
            continue;
        end
    end
end

varFname = strcat(varFnameTemplate,num2str(R));
save(varFname,'featureVector');
s = sprintf('Saved variable %s.mat',varFname);
disp(s);
disp('Done!');

end




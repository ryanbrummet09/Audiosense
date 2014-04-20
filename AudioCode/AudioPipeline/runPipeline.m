function [ featureVector ] = runPipeline(mfccCoff, frequency, fileList)
%RUNPIPELINE An example pipeline structure
%   
addpath voicebox;
addpath preprocess;
mlock;
if nargin < 3
    fileList = false;
end

if ~fileList
    [fname,pname] = uigetfile('*.audio','MultiSelect','on');
    fname = strcat(pname,fname);
else
    [fileWithList, fLPname] = uigetfile('*.txt');
    % get all the filenames with paths
    fname = importdata(strcat(fLPname,fileWithList));
end
h = waitbar(0,'Initializing Calculations');
featureVector = [];
rmsThreshold = 96.766923584390270; % emperically determined
for P=1:length(fname)        
    f = fname{P};
    [locs_buzz, locs_beep, audioSignal] = preProcess(f);
    [buzzMask, beepMask, frames] = framing(audioSignal,frequency,0.02, locs_buzz, locs_beep);
    LowEnergyMask = false(1,length(frames));
    %waitbar(0,h,'Initializing calculations');
    for Q=1:length(frames)
        s = sprintf('Operating on frame # %d of %d \n for \n %s \n(file %d of %d)',Q,length(frames),fname{P},P,length(fname));
        waitbar(Q/length(frames),h,s);
        lastFrameOfFile = (frames(Q,:)==frames(end,:));
        if buzzMask(Q) | beepMask(Q)
            % drop the frames with buzz or beep
            [ptid,cid,sid] = getInfo(fname{P});
            fv = [];
            fv(1,end+1) = ptid; fv(1,end+1)=  cid; fv(1,end+1) = sid;
            fv(1,end+1:end+18) = 0;
            fv(1,end+1) = buzzMask(Q);  fv(1,end+1) = beepMask(Q);
            featureVector(end+1,:) = fv;
            continue;
        end
        LowEnergyMask(Q) = frameProcessing(frames(Q,:),rmsThreshold);
%         [producedOuput,audioWindow,LowEnergyPercent] = windowing(HighEnergyFrame,LowEnergyMask(Q),8000,lastFrameOfFile);
%         if producedOuput
%             featureVector(end+1,:) = extractAudioFeatures(audioWindow,fname{P},LowEnergyPercent,frequency,mfccCoff);
%         end
        featureVector(end+1,:) = extractFrameFeatures(frames(Q,:),fname{P},frequency,mfccCoff,LowEnergyMask(Q),buzzMask(Q),beepMask(Q));
    end
end
munlock;
end


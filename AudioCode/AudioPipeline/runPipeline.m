function [ featureVector ] = runPipeline(mfccCoff, frequency)
%RUNPIPELINE Summary of this function goes here
%   Detailed explanation goes here
addpath voicebox;
addpath preprocess;
mlock;
[fname,pname] = uigetfile('*.audio','MultiSelect','on');
h = waitbar(0,'Initializing Calculations');
featureVector = [];
for P=1:length(fname)
    f = strcat(pname,fname{P});
    audioSignal = preProcess(f);
    frames = framing(audioSignal,frequency,0.02);
    %waitbar(0,h,'Initializing calculations');
    for Q=1:length(frames)
        s = sprintf('Operating on frame # %d of %d \n for \n %s(file %d of %d)',Q,length(frames),fname{P},P,length(fname));
        waitbar(Q/length(frames),h,s);
        lastFrameOfFile = (frames(Q,:)==frames(end,:));
        [HighEnergyFrame,LowEnergyIndicator] = frameProcessing(frames(Q,:),150);
        [producedOuput,audioWindow,LowEnergyPercent] = windowing(HighEnergyFrame,LowEnergyIndicator,8000,lastFrameOfFile);
        if producedOuput
            featureVector(end+1,:) = extractFeatures(audioWindow,fname{P},LowEnergyPercent,frequency,mfccCoff);
    end
end
munlock;
end


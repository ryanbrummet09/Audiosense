function [ rmsValues,totalRMS,pctl,pname,fname ] = rmsThresholdCalculation( frameSizeInSeconds, frequency )
%RMSTHRESHOLDCALCULATION calculates the various thresholds to choose from
%   Usage:
%   [rmsValues, totalRMS, pctl, path, filename ] = rmsThresholdCalculation(
%   frameSizeInSeconds, Frequency);
%   
%   Input:
%
%           frameSizeInSeconds          :           Frame size to
%                                                   calculate the RMS on
%           Frequency                   :           Sampling frequency
%
%
%   Output:
%           
%           rmsValues               :           rmsValues for each frame of
%                                               each file, stored in a cell
%                                               array
%           totalRMS                :           All RMS values in a single
%                                               array
%           pctl                    :           From 1 to 100, the
%                                               percentile values of RMS 
%                                               over all files
%           path                    :           directory path
%           filename                :           Cell array with filenames
addpath ../voicebox;
addpath ../;
totalRMS = [];
rmsValues = {};
[fname,pname] = uigetfile('*.audio','MultiSelect','on');
subplot(211);
clr = jet(length(fname));
for P = 1:length(fname)
    data = getSoundData(strcat(pname,fname{P}));
    frames = enframe(data, frameSizeInSeconds*frequency, frameSizeInSeconds*frequency,'r');
    %rmsV = [];
    %disp(length(frames));
    rmsV = zeros(1,length(frames));
    for Q = 1:length(frames)
        rmsV(Q) = rms(frames(Q,:));
    end
    rmsValues{end+1} = rmsV;
    hold on;
    h(P) = cdfplot(rmsV);
    set(h(P),'Color',clr(P,:));
    totalRMS = horzcat(totalRMS,rmsV);
end
subplot(212);
cdfplot(totalRMS);
%thresholdV = 0;
pctl = [];
for P=1:1:100
    pctl(end+1) = prctile(totalRMS,P);
end
end


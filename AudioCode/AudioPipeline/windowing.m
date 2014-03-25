function [ producedOutput, windowP, LEPercent ] = windowing( HighEnergyFrame, LowEnergyIndicator, windowSize, lastFrameOfFile )
%WINDOWING Summary of this function goes here
%   Detailed explanation goes here

persistent initialized;
persistent LowEnergySamples;
persistent TotalSamples;
persistent finalWindow;

% initialize the persistent variables in the first run
if isempty(initialized)
    if LowEnergyIndicator
        LowEnergySamples = HighEnergyFrame(1);
        TotalSamples = HighEnergyFrame(1);
        finalWindow = [];
        initialized = true;
        producedOutput = false;
        windowP = [];
        LEPercent = [];
    else
        LowEnergySamples = 0;
        TotalSamples = length(HighEnergyFrame);
        finalWindow = horzcat(finalWindow,HighEnergyFrame);
        initialized = true;
        producedOutput = false;
        windowP = [];
        LEPercent = [];
    end
% if things are already initialized, put them together
else
    if LowEnergyIndicator
        % todo
        LowEnergySamples = LowEnergySamples + HighEnergyFrame(1);
        TotalSamples = TotalSamples + HighEnergyFrame(1);
        producedOutput = false;
        windowP = [];
        LEPercent = [];
    else
        if length(HighEnergyFrame) + length(finalWindow) < windowSize
            % nothing to do, just append the frame
            producedOutput = false;
            windowP = [];
            LEPercent = [];
            finalWindow = horzcat(finalWindow,HighEnergyFrame);
            TotalSamples = TotalSamples + length(HighEnergyFrame);
        elseif length(HighEnergyFrame) + length(finalWindow) == windowSize
            % awesome! an exact match, output
            producedOutput = true;
            finalWindow = horzcat(finalWindow,HighEnergyFrame);
            TotalSamples = TotalSamples + length(HighEnergyFrame);
            windowP = finalWindow;
            LEPercent = LowEnergySamples./TotalSamples;
            finalWindow = [];
            LowEnergySamples = 0;
            TotalSamples = 0;
        else
            % the length is greater than the windowsize, we shall randomly
            % choose the remaining elements from the input frame and save
            % the frame for later windows
            producedOutput = true;
            r = datasample(HighEnergyFrame,windowSize-length(finalWindow));
            TotalSamples = TotalSamples + windowSize - length(finalWindow);
            finalWindow = horzcat(finalWindow, r);
            windowP = finalWindow;
            LEPercent = LowEnergySamples./TotalSamples;
            finalWindow = HighEnergyFrame;
            LowEnergySamples = 0;
            TotalSamples = length(HighEnergyFrame); 
        end
    end
end

% make sure that if the current frame is the last frame of the file and the window has not been constructed, output whatever we have
if lastFrameOfFile
    % the condition when the length of the finalWindow is less than the
    % windowSize
    if length(finalWindow) < windowSize
        r = datasample(finalWindow,windowSize-length(finalWindow)); %fill the remaining elements randomly
        finalWindow = horzcat(finalWindow,r);
    end
    producedOutput = true;
    windowP = finalWindow;
    LEPercent = LowEnergySamples/TotalSamples;
    finalWindow = [];
    LowEnergySamples = 0;
    TotalSamples = 0;
end

end


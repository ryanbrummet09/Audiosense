function [ producedOutput, windowP, LEPercent ] = windowing( AudioFrame, LowEnergyIndicator, windowSize, lastFrameOfFile )
%WINDOWING creates windows of the input signal
%   This puts together a bunch of frames, specified by the user, to create
%   a window of audio samples.
%   
%   Input: (AudioFrame, LowEnergyIndicator, windowSize, lastFrameOfFile)
%   AudioFrame              :       Frame of audio signal
%   LowEnergyIndicator      :       bit indicating whether the frame is a
%                                   low energy frame or not
%   windowSize              :       window size in samples
%   lastFrameOfFiles        :       whether the frame is the last frame of
%                                   the file
%
%
%   Output: [producedOutput, windowP, LEPercent]
%   producedOutput          :       Flag indicating whether there is a
%                                   window produced in this particular call
%   windowP                 :       the window of audio samples
%   LEPercent               :       percentage of the samples that have
%                                   been designated as 'low-energy'
%
%   See also, RMSFILTER, FRAMEPROCESSING 

persistent initialized;
persistent LowEnergySamples;
persistent TotalSamples;
persistent finalWindow;

% initialize the persistent variables in the first run
if isempty(initialized)
    if LowEnergyIndicator
        LowEnergySamples = length(AudioFrame);
    else
        LowEnergySamples = 0;
    end
    TotalSamples = length(AudioFrame);
    finalWindow = horzcat(finalWindow,AudioFrame);
    initialized = true;
    producedOutput = false;
    windowP = [];
    LEPercent = [];
% if things are already initialized, put them together
else
    if length(AudioFrame) + length(finalWindow) < windowSize
        % nothing to do, just append the frame
        producedOutput = false;
        windowP = [];
        LEPercent = [];
        finalWindow = horzcat(finalWindow,AudioFrame);
        TotalSamples = TotalSamples + length(AudioFrame);
        if LowEnergyIndicator
            LowEnergySamples = LowEnergySamples + length(AudioFrame);
        end
    elseif length(AudioFrame) + length(finalWindow) == windowSize
        % awesome! an exact match, output
        producedOutput = true;
        finalWindow = horzcat(finalWindow,AudioFrame);
        TotalSamples = TotalSamples + length(AudioFrame);
        if LowEnergyIndicator
            LowEnergySamples = LowEnergySamples + length(AudioFrame);
        end
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
        r = datasample(AudioFrame,windowSize-length(finalWindow));
        TotalSamples = TotalSamples + windowSize - length(finalWindow);
        finalWindow = horzcat(finalWindow, r);
        if LowEnergyIndicator
            LowEnergySamples = LowEnergySamples + length(AudioFrame);
        end
        windowP = finalWindow;
        LEPercent = LowEnergySamples./TotalSamples;
        finalWindow = AudioFrame;
        LowEnergySamples = 0;
        TotalSamples = length(AudioFrame); 
    end
end

% make sure that if the current frame is the last frame of the file and the window has not been constructed, output whatever we have
% THIS IS NOT GOING TO OCCUR NOW, BUT I SHALL KEEP THIS JUST TO BE ON THE
% SAFE SIDE
if lastFrameOfFile
    % the condition when the length of the finalWindow is less than the
    % windowSize
    if length(finalWindow) < windowSize
        r = datasample(finalWindow,windowSize-length(finalWindow)); %fill the remaining elements randomly
        finalWindow = horzcat(finalWindow,r);
    end
    producedOutput = true;
    windowP = finalWindow;
    if LowEnergyIndicator
        LowEnergySamples = LowEnergySamples + length(AudioFrame);
    end
    LEPercent = LowEnergySamples./TotalSamples;
    finalWindow = [];
    LowEnergySamples = 0;
    TotalSamples = 0;
end

end


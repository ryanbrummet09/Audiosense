function [ AvgLinearEnergy ] = AverageLinearEnergy( featureFrames, windowSizeInSeconds, Frequency, frameSizeInSamples, takeLog )
%AVERAGELINEARENERGY mean energies
%   Calculates the mean energies according to the specified window size.
%   Finally, the log10 is operated upon this value.
%   Taken from "Features for segmenting and classifying long-duration
%   recordings of personal audio" by Ellis and Lee
%   
%   Input:
%           featureFrames       :       Frames of the energy feature for 
%                                       which the
%                                       average linear energy has to be 
%                                       calculated
%           windowSizeInSeconds :       Size of the window (long term
%                                       feature) in seconds
%           Frequency           :       The sampling frequency of the
%                                       signal
%           frameSizeInSamples  :       The size of the frames in samples,
%                                       which are to be considered while 
%                                       computing long-term features
%           takeLog             :       Boolean flag indicating whether to
%                                       take a log on the final calculated
%                                       value
%
%   Output:
%           AvgLinearEnergy     :       The vector containing the various
%                                       calculated energies
%
%   Usage:
%           AvgLinearEnergy =
%           AverageLinearEnergy(featureFrame,windowSizeInSeconds,
%           Frequency, frameSizeInSamples, takeLog);
if nargin == 4
    takeLog = false;
elseif nargin == 5 & (takeLog ~= true & takeLog ~= false)
    takeLog = true;
elseif nargin < 4
    emsg = sprintf('Required number of arguments = 4 or 5, given %d',nargin);
    error('AudioPipeline:HigherLevelFeatures:AverageLinearEnergy',emsg);
end
windowSizeInSamples = windowSizeInSeconds * Frequency;
framesPerWindow = floor(windowSizeInSamples/frameSizeInSamples);
AvgLinearEnergy = [];

for P=1:framesPerWindow:length(featureFrames)
    if length(featureFrames) <= P+framesPerWindow
        lastElement = length(featureFrames);
    else
        lastElement = P+framesPerWindow-1;
    end
    temp = mean(featureFrames(P:lastElement));
    if takeLog
        AvgLinearEnergy(end+1) = log10(temp);
    else
        AvgLinearEnergy(end+1) = temp;
    end
end

end


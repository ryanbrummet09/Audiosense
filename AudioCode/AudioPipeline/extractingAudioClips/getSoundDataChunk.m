function [dataChunks] = getSoundDataChunk(data,...
    startPointInSeconds, endPointInSeconds, samplingFrequency)
%GETSOUNDDATACHUNK extracts a part of the file
%   Input:
%           data                :       sound data
%           startPointInSeconds :       the array containing the starting
%                                       points for the chunks
%           endPointsInSeconds  :       the array containing the end points
%                                       for the chunks. This has to be the
%                                       same number as the starting points.
%           samplingFrequency   :       the frequency at which the data was
%                                       sampled
% 
% 
%   Output:
%           dataChunks          :       the output contains as many arrays
%                                       as the length of the start and end
%                                       point arrays.
% 
% 
%   Usage:
%           dataChunks = getSoundDataChunk(data, [10, 20], [15, 25], 16000)
% 
%   @author: syedshabihhasan
addpath ../;
if length(startPointInSeconds) ~= length(endPointInSeconds)
    disp(sprintf('unequal number of start and end points'));
    return;
end
startSample = startPointInSeconds*samplingFrequency;
endSample = endPointInSeconds*samplingFrequency;
dataChunks = cell(length(startSample),1);
for P=1:length(startSample)
    st = startSample(P);
    if 0 == st
        st = 1;
    end
    en = endSample(P);
    disp(sprintf('st:%d, en:%d',st,en));
    temp = data(st:en);
    dataChunks{P} = temp;
end
end



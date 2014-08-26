function [ varargout ] = getSoundDataChunk(data,...
    startPointInSeconds, endPointInSeconds, samplingFrequency)
%GETSOUNDDATACHUNK extracts a part of the file
%   Input:
%           data                :       data extracted from sound file
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
%           varargout           :       the output contains as many arrays
%                                       as the length of the start and end
%                                       point arrays.
% 
% 
%   Usage:
%           dataChunks = getSoundDataChunk(data, [10, 20]. [15, 25], 16000)
% 
%   @author: syedshabihhasan

if length(startPointInSeconds) ~= length(endPointInSeconds)
    disp(sprintf('unequal number of start and end points'));
    return;
end
startSample = startPointInSeconds*samplingFrequency;
endSample = endPointInSeconds*samplingFrequency;
tempOut ={};
for P=1:length(startSample)
    st = startSample(P);
    en = endSample(P);
    temp = data(st:end);
    tempOut{end+1} = temp;
end
varargout = tempOut;
end



function [ labelAssignment ] = assignLabels( labelTimings,frameLength,...
                                             audioFileLength)
%ASSIGNLABELS Returns the frame numbers with corresponding labels
%   This function is used to find out the frame numbers for the given
%   labels. The parameters are as follow:
%   
%   Input:
%           labelTimings            :           This is a cell array with 3
%                                               columns. The 1st column is
%                                               the start time of the
%                                               label, the 2nd column is
%                                               the end time of the label,
%                                               and the 3rd column is the
%                                               actual label. For example.
%                                               {0.3,4.5,'label1';
%                                               4.2,5.6,'label2'}
%           frameLength             :           The length of frames in
%                                               seconds (optional, default
%                                               is 0.064s)
%           audioFileLength         :           The length of the audio
%                                               file in seconds (optional,
%                                               default is 90s)
% 
%   Output:
%           labelAssignment         :           This is a cell array with 3
%                                               columns. The 1st column is
%                                               the frame number for the
%                                               starting time, the 2nd
%                                               column is the frame number
%                                               for the ending time, and
%                                               the 3rd column is the
%                                               actual label.
% 

if 1 == nargin
    frameLength = 0.064;
    audioFileLength = 90;
elseif 2 == nargin
    audioFileLength = 90;
end

labelAssignment = cell(size(labelTimings));
%% get the limits of the frame
frameTimes = 0:frameLength:audioFileLength;
frameLimits = [];
for P=2:length(frameTimes)
    frameLimits(P-1,1) = frameTimes(P-1);
    frameLimits(P-1,2) = frameTimes(P);
end
if 0~=mod(audioFileLength,frameLength)
       frameLimits(end+1,1) = frameLimits(end,2);
       frameLimits(end,2) = audioFileLength;
end
%% get the frames numbers for the label assignments
[r,c] = size(labelTimings);
for P=1:r
    startTime = labelTimings{P,1};
    endTime = labelTimings{P,2};
    if endTime < startTime
        temp = startTime;
        startTime = endTime;
        endTime = temp;
    end
    label = labelTimings{P,3};
    startFrame = -1;
    endFrame = -1;
    for Q=1:length(frameLimits)
        if frameLimits(Q,1) <= startTime & frameLimits(Q,2) >= startTime
            startFrame = Q;
        end
        if frameLimits(Q,1) <= endTime & frameLimits(Q,2) >= endTime
            endFrame = Q;
        end
    end
    labelAssignment{P,1} = startFrame;
    labelAssignment{P,2} = endFrame;
    labelAssignment{P,3} = label;
end

end


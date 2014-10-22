function [ labelVector ] = getLabelVectors(labelAssignments, labelOrder,...
                                            numberOfFrames)
%GETLABELVECTORS Return the label vector for classification
%   Input:
%           labelAssignments        :       Output of ASSIGNLABELS
%           labelOrder              :       Order in which the labels
%                                           should appear in the columns
%           numberOfFrames          :       Number of frames in the audio
%                                           file
% 
%   Output:
%           labelVector             :       Each column is a vector,
%                                           containing 1 in the row if the
%                                           corresponding label is present,
%                                           else it contains a -1
% 
%  See also ASSIGNLABELS
%                                       
if 2 == nargin
    frameLength = 0.064;
    audioFileLength = 90;
elseif 3 == nargin
    audioFileLength = 90;
end
m = numberOfFrames;
n = length(labelOrder);
labelVector = ones(m,n).*(-1);
[r,c] = size(labelAssignments);
for P=1:r
    idx = find(strcmpi(labelOrder,labelAssignments{P,3}));
    labelVector(labelAssignments{P,1}:labelAssignments{P,2},idx) = 1;
end
end


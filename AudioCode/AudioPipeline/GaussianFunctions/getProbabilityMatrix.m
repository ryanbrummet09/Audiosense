function [ prMatrix ] = getProbabilityMatrix( dataSet,k,individualProb,...
                        numberOfLabels)
%GETPROBABILITYMATRIX creates the probability matrix
%   Input:
%           dataSet         :           Dataset containing features, this 
%                                       is a matrix
%           k               :           the number of gaussians
%           individualProb  :           flag to indicate if the
%                                       probabilities would be calculated
%                                       individually for each frame and
%                                       stored as such
%           numberOfLabels  :           the number of distinct labels
%                                       present
% 
%   Output:
%           prMatrix        :           matrix containing the information
%                                       of all patients

if 2 == nargin
    individualProb = false;
    numberOfLabels = 0;
end
if individualProb
    [r,c] = size(dataSet);
    prMatrix = zeros(r,k+4+numberOfLabels);
else
    pids = dataSet(:,1);
    cids = dataSet(:,2);
    sids = dataSet(:,3);
    labels = dataSet(:,4);

    temp = {};
    for P=1:length(pids)
        temp{end+1} = strcat(num2str(pids(P)),'_',num2str(cids(P)),'_',...
                             num2str(sids(P)),'_',num2str(labels(P)));
    end
    temp = unique(temp);
    n = length(temp);
    prMatrix = zeros(n,k+4);
    for P=1:n
        t = temp{P};
        t = strsplit(t,'_');
        prMatrix(P,1) = str2num(t{1});
        prMatrix(P,2) = str2num(t{2});
        prMatrix(P,3) = str2num(t{3});
        prMatrix(P,4) = str2num(t{4});
    end
end
end


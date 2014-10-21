function [ prMatrix ] = getProbabilityMatrix( dataSet, k )
%GETPROBABILITYMATRIX creates the probability matrix
%   Input:
%           dataSet         :           Dataset containing features, this 
%                                       is a matrix
%           k               :           the number of gaussians
% 
%   Output:
%           prMatrix        :           matrix containing the information
%                                       of all patients

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
prMatrix = zeros(n,k+3);
for P=1:n
    t = temp{P};
    t = strsplit(t,'_');
    prMatrix(P,1) = str2num(t{1});
    prMatrix(P,2) = str2num(t{2});
    prMatrix(P,3) = str2num(t{3});
    prMatrix(P,4) = str2num(t{4});
end
end


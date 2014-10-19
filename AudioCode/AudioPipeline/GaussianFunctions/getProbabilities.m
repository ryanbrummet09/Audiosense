function [ prMatrix ] = getProbabilities( GMMObject, dataSet, ...
                                            k, prMatrix,...
                                            softCoding)
%GETPROBABILITIES get the probability distribution of each point
%   Input:
%           GMMObject           :           The GMM object obtained from
%                                           FITGAUSSIANDISTRIBUTIONS
%           dataSet             :           Dataset which needs the
%                                           probabilities, this is a matrix
%           k                   :           The number of gaussians in the
%                                           GMMObject
%           prMatrix            :           The matrix that needs to be
%                                           filled with the probabilities,
%                                           each row represents one file
%           softCoding          :           this is an optional flag which
%                                           should be set to true when one
%                                           wants to work with the actual
%                                           probabilities of the data point
%                                           being a particular gaussian
%                                           rather than the gaussian which
%                                           has the highest probability

if 4 == nargin
    softCoding = false;
end
dataSet = normValues(dataSet);
allMu = GMMObject.mu;
allSigma = GMMObject.Sigma;
[r,c] = size(dataSet);
gaussProbs = posterior(GMMObject,dataSet(:,5:end));
for P=1:r
    if softCoding
            tempV = prMatrix(prMatrix(:,1)==dataSet(P,1) & ...
                    prMatrix(:,2)==dataSet(P,2) & ...
                    prMatrix(:,3)==dataSet(P,3) & ...
                    prMatrix(:,4)==dataSet(P,4),5:end);
            prMatrix(prMatrix(:,1)==dataSet(P,1) & ...
                prMatrix(:,2)==dataSet(P,2) & ...
                prMatrix(:,3)==dataSet(P,3) & ...
                prMatrix(:,4)==dataSet(P,4),5:end) = tempV + ...
                                                     gaussProbs(P,:);
    else
        idx = find(gaussProbs(P,:) == max(gaussProbs(P,:)));
        tempV = prMatrix(prMatrix(:,1)==dataSet(P,1) & ...
                prMatrix(:,2)==dataSet(P,2) & ...
                prMatrix(:,3)==dataSet(P,3) & ...
                prMatrix(:,4)==dataSet(P,4),4+idx);
        prMatrix(prMatrix(:,1)==dataSet(P,1) & ...
                prMatrix(:,2)==dataSet(P,2) & ...
                prMatrix(:,3)==dataSet(P,3) & ...
                prMatrix(:,4)==dataSet(P,4),4+idx) = tempV+1;
    end
end

end


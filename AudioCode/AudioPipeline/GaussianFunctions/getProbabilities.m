function [ prMatrix ] = getProbabilities( GMMObject, dataSet, ...
                                            k, prMatrix,...
                                            includesLabelVector,...
                                            numberOfLabels,softCoding)
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
%           includesLabelVector :           flag to indicate that the label
%                                           vectors are present in the
%                                           dataSet
%           numberOfLabels      :           the number of distinct labels
%           softCoding          :           this is an optional flag which
%                                           should be set to true when one
%                                           wants to work with the actual
%                                           probabilities of the data point
%                                           being a particular gaussian
%                                           rather than the gaussian which
%                                           has the highest probability

if 4 == nargin
    softCoding = false;
    includesLabelVector = false;
    numberOfLabels = 0;
elseif 5==nargin
%     since the number of labels has not been specified, we do not want to
%     take them into account
    softCoding = false;
    includesLabelVector = false;
    numberOfLabels = 0;
elseif 6 == nargin
    softCoding = false;
end
dataSet = normValues(dataSet,numberOfLabels);
allMu = GMMObject.mu;
allSigma = GMMObject.Sigma;
[r,c] = size(dataSet);
gaussProbs = posterior(GMMObject,dataSet(:,5:end-numberOfLabels));
if ~includesLabelVector
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
else
    for P=1:r
        if softCoding
            prMatrix(P,1:4) = dataSet(P,1:4);
            prMatrix(P,5:4+k) = gaussProbs(P,:);
            prMatrix(P,5+k:end) = dataSet(P,end-numberOfLabels+1:end);
        else
            prMatrix(P,1:4) = dataSet(P,1:4);
            idx = find(gaussProbs(P,:) == max(gaussProbs(P,:)));
            prMatrix(P,4+idx) = 1;
            prMatrix(P,5+k:end) = dataSet(P,end-numberOfLabels+1:end);
        end
    end
end

end


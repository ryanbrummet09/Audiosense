function [ trainingSet, testingSet, GMMSet ] = createTestingTrainingSet( trueFeatureMatrix )
%CREATETESTINGTRAININGSET creates the training and test sets of features
%   This function randomly subsamples the input data. The size of the
%   training set is 90% of the input feature matrix. The testing set is the
%   remaining data.
%   
%   Input:
%           trueFeatureMatrix       :       feature matrix obtained from
%                                           getTrueFeatures
%
%   Output:
%           trainingSet             :       Training set, created by random
%                                           subsampling (w/o replacement).
%                                           The size is 90% the size of the
%                                           feature matrix
%           testingSet              :       Testing set, containing the        
%                                           remaining elements (the ones
%                                           not selected by the training
%                                           set.
%           GMMSet                  :       Randomly subsampled training
%                                           set (with replacement) for
%                                           creating the GMM
%   Usage:
%   [trainingSet, testingSet] = createTestingTrainingSet(trueFeatureMatrix)
%
%   See also GETTRUEFEATURES, DATASAMPLE
[r c] = size(trueFeatureMatrix);
trainingSetSize = ceil(0.9 .* r);
[trainingSet, idx] = datasample(trueFeatureMatrix,trainingSetSize);
testingSet = [];
[GMMSet,gmmidx] = datasample(trainingSet,ceil(0.6*trainingSetSize),true);
for P=1:length(trueFeatureMatrix)
    if isempty(find(idx==P))
        testingSet(end+1,:) = trueFeatureMatrix(P,:);
    end
end
end


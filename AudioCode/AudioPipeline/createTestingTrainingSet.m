function [ trainingSet, testingSet ] = createTestingTrainingSet( trueFeatureMatrix )
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
%                                           subsampling (with replacement).
%                                           The size is 90% the size of the
%                                           feature matrix
%           testingSet              :       Testing set, containing the        
%                                           remaining elements (the ones
%                                           not selected by the training
%                                           set.
%   Usage:
%   [trainingSet, testingSet] = createTestingTrainingSet(trueFeatureMatrix)
%
%   See also GETTRUEFEATURES, DATASAMPLE

trainingSetSize = ceil(0.9 .* length(trueFeatureMatrix));
[trainingSet, idx] = datasample(trueFeatureMatrix,trainingSetSize,true);
testingSet = [];
for P=1:length(trueFeatureMatrix)
    if isempty(find(idx==P))
        testingSet(end+1,:) = trueFeatureMatrix(P,:);
    end
end
end


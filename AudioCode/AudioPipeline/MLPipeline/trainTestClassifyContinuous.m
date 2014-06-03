function [ meanError, medianError ] = trainTestClassifyContinuous( ...
    GMMHistWithTargetTraining, GMMHistWithTargetTesting, MLAlgo )
%TRAINTESTCLASSIFYCONTINUOUS classifies and calculates the prediction error
%   This function is used to classify and calculate the error for
%   continuous target variables. The inputs and outputs are mentioned
%   below.
%
%       Input:
%               GMMHistWithTargetTraining   :   GMM Histogram of the audio
%                                               files with the target
%                                               variable for prediction as
%                                               the last column. This is
%                                               the training set.
%               GMMHistWithTargetTesting    :   GMM Histogram of the audio
%                                               files with the target
%                                               variable for prediction as
%                                               the last column. This is
%                                               the testing set.
%               MLAlgo                      :   The machine learning
%                                               algorithm's function
%                                               handle. We currently only
%                                               support two viz.,
%                                               @knnsearch and @svmtrain.
%                                               The default choice is
%                                               @svmtrain.
%       Output:
%               meanError                   :   The mean of the absolute
%                                               errors of prediction.
%               medianError                 :   The median of the absolute
%                                               errors of prediction.
% 
%       Usage:
%       [ meanError, medianError ] = trainTestClassifyContinuous( ...
%       GMMHistWithTargetTraining, GMMHistWithTargetTesting, @svmtrain );
%               

if 2 == nargin
    MLAlgo = @svmtrain;
end
%% check the type of algorithm to use
if isequal(MLAlgo,@knnsearch)
%% knn based search
    predictedIndices = feval(MLAlgo,GMMHistWithTargetTraining(:,4:end-1),GMMHistWithTargetTesting(:,4:end-1), 'K',3);
    predictedValue = nan(length(predictedIndices,1));
    for P=1:length(predictedIndices)
        pred1 = GMMHistWithTargetTraining(predictedIndices(P,1),end);
        pred2 = GMMHistWithTargetTraining(predictedIndices(P,2),end);
        pred3 = GMMHistWithTargetTraining(predictedIndices(P,3),end);
        predictedValue(P) = mean([pred1,pred2,pred3]);
    end
    groundTruth = GMMHistWithTargetTraining(:,end);
else
%% svm based search
    MLAlgo = @svmtrain;
    % train the SVM
    svmStruct = feval(MLAlgo,GMMHistWithTargetTraining(:,4:end-1),GMMHistWithTargetTraining(:,end));
    % classify
    predictedValue = svmclassify(svmStruct,GMMHistWithTargetTesting(:,4:end-1));
    % extract the ground truth
    groundTruth = GMMHistWithTargetTraining(:,end);
    % calculate the prediction error

end
%% error calculation
% extract the mean and median of absolute errors
predictionError = groundTruth - predictedValue;
meanError = mean(abs(predictionError));
medianError = median(abs(predictionError));
end


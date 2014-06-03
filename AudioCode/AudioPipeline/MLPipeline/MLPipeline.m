function [ resultDataset ] = MLPipeline( cvSet, startIndex, endIndex, ...
    surveyDataset, targetVariableName, MLAlgo, outerFoldNumber )
%MLPIPELINE A sample machine learning pipeline
%   Input :
%               cvSet               :       The cross validation set,
%                                           containing the list of files
%                                           with their full paths.
%               startIndex, endIndex:       The column numbers to consider
%                                           in the feature vector for
%                                           calculating the GMM Object.
%               surveyDataset       :       Dataset containing the
%                                           information from the surveys
%                                           collected.
%               targetVariableName  :       The variable from the dataset
%                                           to make predictions on.
%               MLAlgo              :       The function handler of the
%                                           machine learning algorithm to
%                                           use. Currently we only support
%                                           @knnsearch and @svmtrain
%               outerFoldNumber     :       The outer fold number, this is
%                                           to keep track of which set is
%                                           being used as the validation
%                                           set.
%   
%   Output:
%               resultDataset       :       The dataset containing the
%                                           results of the machine
%                                           learning, they depend on
%                                           whether the prediction was
%                                           carried out on a variable that
%                                           was discrete or continuous

%% add dependencies
addpath ../;
addpath ../HighLevelFeatures/;

%% create the structure for dataset
opCell = {};
opCell{1,1} = 'OuterFold';
opCell{1,2} = 'InnerFold';
opCell{1,3} = 'NumberOfGaussians';
opCell{1,4} = 'Continuous'
opCell{1,5} = 'MeanError';
opCell{1,6} = 'MedianError';
opCell{1,7} = 'Accuracy';
opCell{1,8} = 'Precision';
opCell{1,9} = 'Recall';
%% get the actual features out of the files
K = length(cvSet);
newCVSet = {};
for P=1:K
    newCVSet{P,1} = getAndAppend(cvSet{P,1});
end

%% choose each of the sets to be the testing set
for P=1:length(newCVSet);
    testingSet = newCVSet{P,1};
    trainingSet = [];
    for Q=1:length(newCVSet)
        if Q ~= P
            trainingSet = [trainingSet; newCVSet{Q,1}];
        else
            continue;
        end
    end
    
    % remove the low energy frames as well as the buzz and beep frames
    trainingSet = getTrueFeatures(trainingSet);
    testingSet = getTrueFeatures(testingSet);
    
    % get the GMM set
    GMMSet = createGMMSet(trainingSet);
    
    % create the GMM Objects with different number of Gaussians(2^5 - 2^10)
    for R = 5:1:10
        numberOfGaussians = pow2(R);
        GMMObject = getGMMObject(GMMSet,startIndex,endIndex,...
            numberOfGaussians);
        
        % once we have the GMM Object, we shall create the Histogram for
        % both the training as well as the testing set
        GMMHistogramTrainingSet = GMMHistogram(trainingSet, GMMObject, ...
            startIndex, endIndex);
        GMMHistogramTestingSet = GMMHistogram(testingSet, GMMObject, ...
            startIndex, endIndex);
        
        % now that we have the GMM Histograms, we add the target variables
        % to both the training as well as the testing sets
        GMMHistWithTargetTraining  = addTargetVariable( ...
            GMMHistogramTrainingSet, surveyDataset, targetVariableName);
        GMMHistWithTargetTesting = addTargetVariable( ...
            GMMHistogramTestingSet, surveyDataset, targetVariableName);
        
        % remove the rows with the target being NaN
        GMMHistWithTargetTraining = GMMHistWithTargetTraining(...
            ~isnan(GMMHistWithTargetTraining(:,end)));
        GMMHistWithTargetTesting = GMMHistWithTargetTesting(...
            ~isnan(GMMHistWithTargetTesting(:,end)));
        
        % the ML part comes next
        [meanError, medianError] = trainTestClassifyContinuous(...
            GMMHistWithTargetTraining,GMMHistWithTargetTesting, MLAlgo);
        % start saving the outputs
        
        gmmobjFname = sprintf('GMMObj/gmmObj_%d_%d_%d',outerFoldNumber,...
            P, numberOfGaussians);
        opCell{end+1,1} = outerFoldNumber;  opCell{end,2} = P;    
        opCell{end,3} = numberOfGaussians;
        opCell{end,4} = true;  opCell{end,5} = meanError;
        opCell{end,6} = medianError; opCell{end,7} = nan;
        opCell{end,8} = nan;    opCell{end,9} = nan;
        save(gmmobjFname,'GMMObject');
    end
end
resultDataset = cell2dataset(opCell);
end


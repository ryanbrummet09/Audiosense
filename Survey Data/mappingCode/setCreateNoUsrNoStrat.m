%Author Ryan Brummet
%University of Iowa

function [ trainingSet, testingSet, trainingIndex, testingIndex, currentSampleCountTraining, ...
    currentSampleCountTesting, currentSampleTrainingIndexes, ...
    currentSampleTestingIndexes] = setCreateNoUsrNoStrat(trainingIndex,... 
    testingIndex, currentSampleCountTraining, currentSampleCountTesting, ...
    currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData)

%trainingIndex (input/output int): current next unused row of trainingSet

%testingIndex (input/output int): current next unused row of testingSet

%currentSampleCountTraining (input/output matrix): gives the number of
%       samples from each user that are in the training set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleCountTesting (input/output matrix): gives the number of 
%       samples from each user that are int the testing set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleTrainingIndexes (input/output matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in 
%       the training set. the input is a matrix of zeros.

%currentSampleTestingIndexes (input/output matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in
%       the testing set.  The input is a matrix of zeros.

%inputData (input matrix): gives the overall patient data matrix

%trainingSet (output matrix): subset of the overall patient data matrix
%       that will be used as a training set to map attributes

%testingSet (output matrix): subset of the overall patient data matrix that
%       will be used as a testing set for the attribute mappings


    trainingSetSize = floor(size(inputData,1) * .8);
	trainingSetIndexes = randperm(size(inputData,1),trainingSetSize);
    for k = 1 : size(inputData,1)
        if ismember(k,trainingSetIndexes)
            trainingSet(trainingIndex,:) = inputData(k,:);
            trainingIndex = trainingIndex + 1;
            temp = find(currentSampleCountTraining(:,1) == inputData(k,1));
            currentSampleCountTraining(temp,2) = currentSampleCountTraining(temp,2) + 1;
            currentSampleTrainingIndexes(temp,k) = k;
        else
            testingSet(testingIndex,:) = inputData(k,:);
            testingIndex = testingIndex + 1;
            temp = find(currentSampleCountTesting(:,1) == inputData(k,1));
            currentSampleCountTesting(temp,2) = currentSampleCountTesting(temp,2) + 1;
            currentSampleTestingIndexes(temp,k) = k;
        end
    end
end


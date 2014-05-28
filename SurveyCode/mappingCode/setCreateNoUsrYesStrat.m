%Author Ryan Brummet
%University of Iowa

function [ trainingSet, testingSet, trainingIndex, testingIndex, currentSampleCountTraining, ...
    currentSampleCountTesting, currentSampleTrainingIndexes, ...
    currentSampleTestingIndexes] = setCreateNoUsrYesStrat(trainingIndex,... 
    testingIndex, userSampleCount, inputData)

%trainingIndex (input/output int) current next unused row of trainingSet

%testingIndex (input/output int) current next unused row of testingSet

%currentSampleCountTraining (output matrix): gives the number of
%       samples from each user that are in the training set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleCountTesting (output matrix): gives the number of 
%       samples from each user that are int the testing set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleTrainingIndexes (output matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in 
%       the training set. the input is a matrix of zeros.

%currentSampleTestingIndexes (output matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in
%       the testing set.  The input is a matrix of zeros.

%usrSampleCount  (input matrix): contains the usr and the number of samples
%       each has. This is passed to the function so as to not have to
%       calculate the information twice.

%inputData (input matrix): gives the overall patient data matrix

%trainingSet (output matrix): subset of the overall patient data matrix
%       that will be used as a training set to map attributes

%testingSet (output matrix): subset of the overall patient data matrix that
%       will be used as a testing set for the attribute mappings


    currentSampleCountTraining = zeros(size(userSampleCount,1),2);
    currentSampleCountTesting = zeros(size(userSampleCount,1),2);
    currentSampleCountTraining(:,1) = userSampleCount(:,1);
    currentSampleCountTesting(:,1) = userSampleCount(:,1);
    currentSampleTrainingIndexes = zeros(size(userSampleCount,1),1);
    currentSampleTestingIndexes = zeros(size(userSampleCount,1),1);
    for k = 0 : floor(size(inputData,1) / 5) - 1
        temp = randi(5);
        for j = 1 : 5
            if j ~= temp
                trainingSet(trainingIndex,:) = inputData((k * 5) + j,:);
                trainingIndex = trainingIndex + 1;
                temp2 = find(currentSampleCountTraining(:,1) == inputData((k * 5) + j,1));
                currentSampleCountTraining(temp2,2) = currentSampleCountTraining(temp2,2) + 1;
                currentSampleTrainingIndexes(temp2,(k * 5) + j) = (k * 5) + j;
            else
                testingSet(testingIndex,:) = inputData((k * 5) + j,:);
                testingIndex = testingIndex + 1;
                temp2 = find(currentSampleCountTesting(:,1) == inputData((k * 5) + j,1));
                currentSampleCountTesting(temp2,2) = currentSampleCountTesting(temp2,2) + 1;
                currentSampleTestingIndexes(temp2,(k * 5) + j) = (k * 5) + j;
            end
        end
    end
    for k = 6 + (floor(size(inputData,1) / 5) - 1) * 5 : size(inputData,1)
        testingSet(testingIndex,:) = inputData(k,:);
        testingIndex = testingIndex + 1;
        temp = find(currentSampleCountTesting(:,1) == inputData(k,1));
        currentSampleCountTesting(temp,2) = currentSampleCountTesting(temp,2) + 1;
        currentSampleTestingIndexes(temp,k) = k;
    end
end


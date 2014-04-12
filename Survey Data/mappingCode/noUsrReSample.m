%Author Ryan Brummet
%University of Iowa

function [ trainingSet, testingSet ] = noUsrReSample(trainingIndex,... 
    testingIndex, trainingSet, testingSet, currentSampleCountTraining, currentSampleCountTesting, ...
    currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData, ...
    userSampleCount)

%trainingIndex (input int) current next unused row of trainingSet

%testingIndex (input int) current next unused row of testingSet

%currentSampleCountTraining (input matrix): gives the number of
%       samples from each user that are in the training set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleCountTesting (input matrix): gives the number of 
%       samples from each user that are int the testing set thus far.  The
%       input is a matrix of zeros with patient id's only.

%currentSampleTrainingIndexes (input matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in 
%       the training set. the input is a matrix of zeros.

%currentSampleTestingIndexes (input matrix): gives the index of each
%       sample in the overall patient data matrix for each user sample in
%       the testing set.  The input is a matrix of zeros.

%inputData (input matrix): gives the overall patient data matrix

%userIndexSet (input matrix): used to determine the number of user there
%       are in the overall patient data matrix without searching through
%       the whole matrix

%trainingSet (input/output matrix): subset of the overall patient data matrix
%       that will be used as a training set to map attributes

%testingSet (input/output matrix): subset of the overall patient data matrix that
%       will be used as a testing set for the attribute mappings


    maximumTraining = max(currentSampleCountTraining(:,2));
    maximumTesting = max(currentSampleCountTesting(:,2));
    for k = 1 : size(userSampleCount,1)
        if  maximumTraining > currentSampleCountTraining(k,2)
            firstRunAmount = currentSampleCountTraining(k,2);
            while currentSampleCountTraining(k,2) < maximumTraining
                temp = find(currentSampleTrainingIndexes(k,:));
                if currentSampleCountTraining(k,2) + firstRunAmount < maximumTraining
                    for j = 1 : size(temp,2)
                        trainingSet(trainingIndex,:) = inputData(currentSampleTrainingIndexes(k,temp(1,j)),:);
                        trainingIndex = trainingIndex + 1;
                        currentSampleCountTraining(k,2) = currentSampleCountTraining(k,2) + 1;
                    end
                else
                    temp2 = randperm(size(temp,2), (maximumTraining - currentSampleCountTraining(k,2)));
                    for j = 1 : size(temp2,2)
                        trainingSet(trainingIndex,:) = inputData(currentSampleTrainingIndexes(k,temp(1,temp2(1,j))),:);
                        trainingIndex = trainingIndex + 1;
                        currentSampleCountTraining(k,2) = currentSampleCountTraining(k,2) + 1;
                    end
                end
            end
        end
        if  maximumTesting > currentSampleCountTesting(k,2)
            firstRunAmount = currentSampleCountTesting(k,2);
            while currentSampleCountTesting(k,2) < maximumTesting
                temp = find(currentSampleTestingIndexes(k,:));
                if currentSampleCountTesting(k,2) + firstRunAmount < maximumTesting
                    for j = 1 : size(temp,2)
                        testingSet(testingIndex,:) = inputData(currentSampleTestingIndexes(k,temp(1,j)),:);
                        testingIndex = testingIndex + 1;
                        currentSampleCountTesting(k,2) = currentSampleCountTesting(k,2) + 1;
                    end
                else
                    temp2 = randperm(size(temp,2), (maximumTesting - currentSampleCountTesting(k,2)));
                    for j = 1 : size(temp2,2)
                        testingSet(testingIndex,:) = inputData(currentSampleTestingIndexes(k,temp(1,temp2(1,j))),:);
                        testingIndex = testingIndex + 1;
                        currentSampleCountTesting(k,2) = currentSampleCountTesting(k,2) + 1;
                    end
                end
            end
        end
    end
end



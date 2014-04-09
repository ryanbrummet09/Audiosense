%Author Ryan Brummet
%University of Iowa

function [ trainingSet, testingSet, trainingIndex, testingIndex, currentSampleCountTraining, ...
    currentSampleCountTesting, currentSampleTrainingIndexes, ...
    currentSampleTestingIndexes ] = setCreateYesUsrYesStrat(trainingIndex,... 
    testingIndex, user, userIndexSet, userSampleCount, currentSampleCountTraining, currentSampleCountTesting, ...
    currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData )

%trainingIndex (input/output int): current next unused row of trainingSet

%testingIndex (input/output int): current next unused row of testingSet

%user (input int): gives the current user that is being examined.  Needed
%       as one of the indice dimensions of several input variables.

%userIndexset (input matrix): contains the index value of samples associated
%       with each user. This is passed to the function so as to not have to 
%       calculate the information twice.

%userSampleCount (input matrix): gives the number of samples each user has
%       in the overall patient data matrix

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

%trainingSet (output 3dArray): subset of the overall patient data matrix
%       that will be used as a training set to map attributes

%testingSet (output 3dArray): subset of the overall patient data matrix that
%       will be used as a testing set for the attribute mappings

    maximum = max(userSampleCount(:,2));
    trainingSet = zeros(maximum,22);
    testingSet = zeros(maximum,22);
    temp1 = find(userIndexSet(user,:));
    for j = 0 : floor(size(temp1,2) / 5) - 1
        temp2 = randperm(5,1);
        for g = 1 : 5
            if g ~= temp2
                trainingSet(trainingIndex(user,1),:) = inputData(userIndexSet(user,temp1(1,(j * 5) + g)),:);
                trainingIndex(user,1) = trainingIndex(user,1) + 1;
                temp = find(currentSampleCountTraining(:,1) == inputData(userIndexSet(user,temp1(1,(j * 5) + g)),1));
                currentSampleCountTraining(temp,2) = currentSampleCountTraining(temp,2) + 1;
                currentSampleTrainingIndexes(temp,userIndexSet(user,temp1(1,(j * 5) + g))) = userIndexSet(user,temp1(1,(j * 5) + g));
            else 
                testingSet(testingIndex(user,1),:) = inputData(userIndexSet(user,temp1(1,(j * 5) + g)),:);
                testingIndex(user,1) = testingIndex(user,1) + 1;
                temp = find(currentSampleCountTesting(:,1) == inputData(userIndexSet(user,temp1(1,(j * 5) + g)),1));
                currentSampleCountTesting(temp,2) = currentSampleCountTesting(temp,2) + 1;
                currentSampleTestingIndexes(temp,userIndexSet(user,temp1(1,(j * 5) + g))) = userIndexSet(user,temp1(1,(j * 5) + g));
            end
        end
    end
    for j = 5 + (floor(size(temp1,2) / 5) - 1) * 5 : size(temp1,2)
        testingSet(testingIndex(user,1),:) = inputData(userIndexSet(user,temp1(1,j),:));
        testingIndex(user,1) = testingIndex(user,1) + 1;
        temp = find(currentSampleCountTesting(:,1) == inputData(userIndexSet(user,temp1(1,j),1)));
        currentSampleCountTesting(temp,2) = currentSampleCountTesting(temp,2) + 1;
        currentSampleTestingIndexes(temp,userIndexSet(user,temp1(1,j))) = userIndexSet(user,temp1(1,j));
    end
end


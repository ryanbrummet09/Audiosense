%Author Ryan Brummet
%University of Iowa

function [RMSDNormVals] = mapAttributes(mapPerUser, ...
    stratifySample, reSample, target, deg, inputData, ...
    userSampleCount, userIndexSet)
%This function maps all the attributes of survey samples set onto a
%single attribute and returns a modified data matrix that reflects this
%mapping.

%  mapPerUsr         (bool): if true mapping is done per user or false if
%                            it is done globally.  If mapping is done per
%                            user stratifySample and userReSample are
%                            automatically false.  If this is not true an
%                            error is thrown.

%  stratifySample    (bool): if true the sampling policy for picking 
%                            training and test sets is stratified by user.
%                            If false, sampling is done at random

%  reSample          (bool): if true each user will be sampled the same
%                            amount of times when picking training and 
%                            testing sets. Can only be true if
%                            stratifySample is true.  The user with the
%                            most samples will not be resampled but the
%                            other samples will be re-sampled to match.
%                            Notice that the training set will compose of
%                            80% of the data and the testing set 20%.

%  target             (int): describes the attribute that all other
%                            attributes will be mapped onto.  1 for sp, 2
%                            for le, 3 for ld, 4 for ld2, 5 for lcl, 6 for
%                            ap, 7 for qol, 8 for im, 9 for st.  Any other
%                            value an error is thrown.

%  deg                (int): gives the degree of the mapping polynomial
%                            function

%  inputData       (matrix): self explanatroy. gives the matrix of input
%                            data

%  usrSampleCount  (matrix): contains the usr and the number of samples
%                            each has. This is passed to the function so as 
%                            to not have to calculate the information 
%                            twice.

%  usrIndexSet     (matrix): contains the index value of samples associated
%                            with each user. This is passed to the function
%                            so as to not have to calculate the information
%                            twice.

%  medianMap         (bool): true if median of all mappings is used to
%                            produce singlur mapping.  false if mean is
%                            used to produce singular mapping.

%  mappedData      (matrix): the input data that is returned where
%                            attributes have been mapped onto one
%                            attribute.

%  mapError        (matrix): the training set error minus the testing set
%                            error.  The error for each set is found by
%                            substracting real values from predicted map
%                            values for each attribute.  The median, mean,
%                            and max across all samples are recorded as the
%                            actuall set error values.

%  mapCoef         (matrix): The coefficients, in descending order, of the
%                            mapping functions for each attribute.

    %make sure that mapping is supposed to occur
    if target < 1 || target > 9
        error('mapAttributes: target value is a non mapping value.'); 
    end
    
    %pick training and testing sets based on sampling policy
    %users in the usrSampleCount matrix with odd numbered rows are sampled such
    %that the sampling amount is rounded down while even numbered users are
    %sampled rounded up.  The user with the highest index gets sampled the
    %remaining amount.
    
    if mapPerUser
        trainingIndex = zeros(size(userIndexSet,1)) + 1;
        testingIndex = zeros(size(userIndexSet,1)) + 1;
        mapCoef = zeros(9,deg + 1, size(userIndexSet,1));
        currentSampleCountTraining = zeros(size(userSampleCount,1),2);
        currentSampleCountTesting = zeros(size(userSampleCount,1),2);
        currentSampleCountTraining(:,1) = userSampleCount(:,1);
        currentSampleCountTesting(:,1) = userSampleCount(:,1);
        currentSampleTrainingIndexes = zeros(size(userSampleCount,1),1);
        currentSampleTestingIndexes = zeros(size(userSampleCount,1),1);
        for k = 1 : size(userIndexSet,1)
            if stratifySample
                [ trainingSet(:,:,k), testingSet(:,:,k), trainingIndex, testingIndex, currentSampleCountTraining, ...
                    currentSampleCountTesting, currentSampleTrainingIndexes, ...
                    currentSampleTestingIndexes ] = setCreateYesUsrYesStrat(trainingIndex,... 
                    testingIndex, k, userIndexSet, userSampleCount, currentSampleCountTraining, currentSampleCountTesting, ...
                    currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData );
            else
                [ trainingSet(:,:,k), testingSet(:,:,k), trainingIndex, testingIndex, currentSampleCountTraining, ...
                    currentSampleCountTesting, currentSampleTrainingIndexes, ...
                    currentSampleTestingIndexes ] = setCreateYesUsrNoStrat(trainingIndex,... 
                    testingIndex, k, userIndexSet, userSampleCount, currentSampleCountTraining, currentSampleCountTesting, ...
                    currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData );
            end
        end
        if reSample
            [ trainingSet, testingSet ] = yesUsrReSample(trainingIndex,... 
                testingIndex, trainingSet, testingSet, currentSampleCountTraining, currentSampleCountTesting, ...
                currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData, ...
                userSampleCount);
        end
        clearvars testingIndex trainingIndex currentSampleCountTesting ...
            currentSampleCountTraining currentSampleTestingIndexes currentSampleTrainingIndexes;

        [RMSDNormVals] = findMapCoefUser( userIndexSet, inputData,...
            trainingSet, testingSet, deg, target);
    else
        testingIndex = 1;
        trainingIndex = 1;
        if stratifySample
            [ trainingSet, testingSet, trainingIndex, testingIndex, currentSampleCountTraining, ...
                currentSampleCountTesting, currentSampleTrainingIndexes, ...
                currentSampleTestingIndexes] = setCreateNoUsrYesStrat(trainingIndex, testingIndex,... 
                userSampleCount, inputData);
        else
            [ trainingSet, testingSet, trainingIndex, testingIndex, currentSampleCountTraining, ...
                currentSampleCountTesting, currentSampleTrainingIndexes, ...
                currentSampleTestingIndexes] = setCreateNoUsrNoStrat(trainingIndex, testingIndex,... 
                userSampleCount, inputData);
        end
        if reSample
            [ trainingSet, testingSet ] = noUsrReSample(trainingIndex,... 
                testingIndex, trainingSet, testingSet, currentSampleCountTraining, currentSampleCountTesting, ...
                currentSampleTrainingIndexes, currentSampleTestingIndexes, inputData, ...
                userSampleCount);
        end
        clearvars testingIndex trainingIndex currentSampleCountTesting ...
            currentSampleCountTraining currentSampleTestingIndexes currentSampleTrainingIndexes;
        
        [RMSDNormVals] = findMapCoefGlobal(inputData, trainingSet, ...
            testingSet, deg, target);
    end
end


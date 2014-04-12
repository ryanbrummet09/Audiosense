%Author Ryan Brummet
%University of Iowa


%This function maps all the attributes of audioSense sample set onto a
%single attribute and returns a modified data matrix that reflects this
%mapping.
function [mappedData, mapError, mapCoef] = mapAttributes(mapPerUsr, ...
    stratifySample, userReSample, target, deg, inputData, ...
    usrSampleCount, usrIndexSet, medianMap)
%  mapPerUsr         (bool): if true mapping is done per user or false if
%                            it is done globally.  If mapping is done per
%                            user stratifySample and userReSample are
%                            automatically false.  If this is not true an
%                            error is thrown.

%  stratifySample    (bool): if true the sampling policy for picking 
%                            training and test sets is stratified by user.
%                            If false, sampling is done at random

%  userReSample      (bool): if true each user will be sampled the same
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
if mapPerUsr && (stratifySample || userReSample)
   error('mapPerUser is true but so is either stratifySample or userReSample'); 
end
%pick training and testing sets based on sampling policy
%users in the usrSampleCount matrix with odd numbered rows are sampled such
%that the sampling amount is rounded down while even numbered users are
%sampled rounded up.  The user with the highest index gets sampled the
%remaining amount.
testingSet = zeros(1,22);
trainingSet = zeros(1,22);
if ~mapPerUsr
    trainingSetSize = floor(size(inputData,1) * .8);
    testingIndex = 1;
    trainingIndex = 1;
    if stratifySample
        if userReSample
            %users may have NaN number of samples so we must manually count
            maximum = length(find(usrIndexSet(1,:)));
            for k = 2 : size(usrSampleCount,1)
                temp1 = length(find(usrIndexSet(k,:))); 
                if temp1 > maximum
                    maximum = temp1;
                end
            end
            clearvars temp1;
            for k = 1 : size(usrSampleCount,1)
                if k ~= size(usrSampleCount,1)
                    if rem(k,2) == 1
                        trainingAmount = floor(trainingSetSize / size(usrSampleCount,1));
                    else
                        trainingAmount = ceil(trainingSetSize / size(usrSampleCount,1));
                    end
                else
                    trainingAmount = ceil(trainingSetSize / size(usrSampleCount,1));
                end
                temp1 = find(usrIndexSet(k,:));
                if trainingAmount >= length(temp1)
                    temp2 = randperm(length(temp1), floor(length(temp1) * .8));
                else
                    temp2 = randperm(length(temp1), trainingAmount);
                end
                for j = 1 : length(temp1)
                    if ismember(j,temp2)
                        trainingSet(trainingIndex,:) = inputData(usrIndexSet(k,j),:);
                        trainingIndex = trainingIndex + 1;
                    else
                        testingSet(testingIndex,:) = inputData(usrIndexSet(k,j),:);
                        testingIndex = testingIndex + 1;
                    end
                end
                if length(temp1) < maximum
                    amount = length(temp1);
                    while(amount + length(temp1) < maximum)
                        if trainingAmount >= length(temp1)
                            temp2 = randperm(length(temp1), floor(length(temp1)*.8));
                        else
                            temp2 = randperm(length(temp1), trainingAmount);
                        end
                        for j = 1 : length(temp1)
                            if ismember(j,temp2)
                                trainingSet(trainingIndex,:) = inputData(usrIndexSet(k,j),:);
                                trainingIndex = trainingIndex + 1;
                            else
                                testingSet(testingIndex,:) = inputData(usrIndexSet(k,j),:);
                                testingIndex = testingIndex + 1;
                            end
                        end
                        amount = amount + length(temp1);
                    end
                    temp2 = randperm(length(temp1), floor((maximum - amount) * .8));
                    for j = 1 : amount - maximum
                        if ismember(j,temp2)
                            trainingSet(trainingIndex,:) = inputData(usrIndexSet(k,j),:);
                            trainingIndex = trainingIndex + 1;
                        else
                            testingSet(testingIndex,:) = inputData(usrIndexSet(k,j),:);
                            testingIndex = testingIndex + 1;
                        end
                    end
                end
            end
        else
            for k = 1 : size(usrSampleCount,1)
                if k ~= size(usrSampleCount,1)
                    if rem(k,2) == 1
                        trainingAmount = floor(trainingSetSize / size(usrSampleCount,1));
                    else
                        trainingAmount = ceil(trainingSetSize / size(usrSampleCount,1));
                    end
                else
                    trainingAmount = ceil(trainingSetSize / size(usrSampleCount,1));
                end
                temp1 = find(usrIndexSet(k,:));
                if trainingAmount >= length(temp1)
                    temp2 = randperm(length(temp1), floor(length(temp1) * .8));
                else
                    temp2 = randperm(length(temp1), trainingAmount);
                end
                for j = 1 : length(temp1)
                    if ismember(j,temp2)
                        trainingSet(trainingIndex,:) = inputData(usrIndexSet(k,j),:);
                        trainingIndex = trainingIndex + 1;
                    else
                        testingSet(testingIndex,:) = inputData(usrIndexSet(k,j),:);
                        testingIndex = testingIndex + 1;
                    end
                end
            end
        end
    else
        trainingSetIndexes = randperm(size(inputData,1),trainingSetSize);
        for k = 1 : size(inputData,1)
            if ismember(k,trainingSetIndexes)
                trainingSet(trainingIndex,:) = inputData(k,:);
                trainingIndex = trainingIndex + 1;
            else
                testingSet(testingIndex,:) = inputData(k,:);
                testingIndex = testingIndex + 1;
            end
        end
    end

    %clear vars that we no longer need
    clearvars trainingSetSize trainingIndex testingIndex max temp1 k trainingAmount temp2 j trainingSetIndexes

    %find mapping function coefficients
    mapCoef = zeros(9,deg + 1);
    for k = 1: 9
        if k ~= target
            index = 1;
            for j = 1 : size(trainingSet,1)
                if (trainingSet(j,13 + target) >= 0) && (trainingSet(j,13 + k) >= 0)
                    temp(index,1) = trainingSet(j,13 + k);
                    temp(index,2) = trainingSet(j,13 + target);
                    index = index + 1;
                end
            end
            %highest degree at highest index
            mapCoef(k,:) = fliplr(polyfit(temp(:,1),temp(:,2),deg));
            clearvars temp;
        else
            mapCoef(k,2) = 1;
            continue;
        end
    end
    clearvars temp k j index;
    adjTestingSet = testingSet;
    for k = 1 : size(testingSet,1)
        for j = 1 : 9
            if j ~= target
                %we must censor our results to be on the interval [0,100]
                convertedVal = 0;
                for g = deg: -1: 0
                    convertedVal = convertedVal + (testingSet(k,13 + j)^g)*mapCoef(j,g + 1);
                end
                if convertedVal > 100
                    adjTestingSet(k,13 + j) = 100;
                elseif convertedVal < 0
                    adjTestingSet(k,13 + j) = 0;
                else
                    adjTestingSet(k,13 + j) = convertedVal;
                end
            end
        end
    end

    clearvars k j g convertedVal
    adjTrainingSet = trainingSet;
    for k = 1 : size(trainingSet,1)
        for j = 1 : 9
            if j ~= target
                %we must censor our results to be on the interval [0,100]
                convertedVal = 0;
                for g = deg: -1: 0
                    convertedVal = convertedVal + (adjTrainingSet(k,13 + j)^g)*mapCoef(j,g + 1);
                end
                if convertedVal > 100
                    adjTrainingSet(k,13 + j) = 100;
                elseif convertedVal < 0
                    adjTrainingSet(k,13 + j) = 0;
                else
                    adjTrainingSet(k,13 + j) = convertedVal;
                end
            end
        end
    end
    for k = 1 : 9
        clearvars temp1Error temp2Error;
        testingErrorIndex = 1;
        trainingErrorIndex = 1;
        for j = 1 : size(testingSet,1)
            if testingSet(j,13 + k) >= 0
                temp1Error(testingErrorIndex) = abs(testingSet(j,13 + k) - adjTestingSet(j,13 + k));
                testingErrorIndex = testingErrorIndex + 1;
            end
        end
        for j = 1 : size(trainingSet,1)
            if trainingSet(j,13 + k) >= 0
                temp2Error(trainingErrorIndex) = abs(trainingSet(j,13 + k) - adjTrainingSet(j,13 + k));
                trainingErrorIndex = trainingErrorIndex + 1;
            end
        end
        testingError(k,1) = mean(temp1Error);
        testingError(k,2) = median(temp1Error);
        testingError(k,3) = max(temp1Error);
        trainingError(k,1) = mean(temp2Error);
        trainingError(k,2) = median(temp2Error);
        trainingError(k,3) = max(temp2Error);
    end
    mapError = abs(testingError - trainingError);
    clearvars testingError trainingError;
    mappedDataTemp = inputData;
    for k = 1 : size(inputData,1)
        for j = 1 : 9
            %we must censor our results to be on the interval [0,100]
            convertedVal = 0;
            for g = deg: -1: 0
                convertedVal = convertedVal + (mappedDataTemp(k,13 + j)^g)*mapCoef(j,g + 1);
            end
            if convertedVal > 100
                mappedDataTemp(k,13 + j) = 100;
            elseif convertedVal < 0
                mappedDataTemp(k,13 + j) = 0;
            else
                mappedDataTemp(k,13 + j) = convertedVal;
            end
        end
    end
else
    mapCoef = zeros(9,deg + 1, size(usrIndexSet,1));
    for k = 1 : size(usrIndexSet,1)
        trainingSetIndex = 1;
        testingSetIndex = 1;
        trainingSetSize = floor(size(find(usrIndexSet(k,:)),2) * .8);
        trainingSetIndexes = randperm(size(find(usrIndexSet(k,:)),2),trainingSetSize);
        for j = 1 : size(trainingSetIndexes,2)
            if ismember(j,trainingSetIndexes)
                trainingSet(trainingSetIndex,:) = inputData(usrIndexSet(k,j),:);
                trainingSetIndex = trainingSetIndex + 1;
            else
                testingSet(testingSetIndex,:) = inputData(usrIndexSet(k,j),:);
                testingSetIndex = testingSetIndex + 1;
            end
        end
        for m = 1: 9
            if m ~= target
                index = 1;
                for j = 1 : size(trainingSet,1)
                    if (trainingSet(j,13 + target) >= 0 && (trainingSet(j,13 + m)) >= 0)
                        temp(index,1) = trainingSet(j,13 + m);
                        temp(index,2) = trainingSet(j,13 + target);
                        index = index + 1;
                    end
                end
                %highest degree at highest index
                mapCoef(m,:,k) = fliplr(polyfit(temp(:,1),temp(:,2),deg));
                clearvars temp;
            else
                mapCoef(m,deg,k) = 1;
                continue;
            end
        end
        adjTestingSet = testingSet;
        for m = 1 : size(testingSet,1)
            for j = 1 : 9
                if j ~= target
                    %we must censor our results to be on the interval [0,100]
                    convertedVal = 0;
                    for g = deg: -1: 0
                        convertedVal = convertedVal + (testingSet(m,13 + j)^g)*mapCoef(j,g + 1,k);
                    end
                    if convertedVal > 100
                        adjTestingSet(m,13 + j) = 100;
                    elseif convertedVal < 0
                        adjTestingSet(m,13 + j) = 0;
                    else
                        adjTestingSet(m,13 + j) = convertedVal;
                    end
                end
            end
        end

        clearvars j g convertedVal
        adjTrainingSet = trainingSet;
        for m = 1 : size(adjTrainingSet,1)
            for j = 1 : 9
                if j ~= target
                    %we must censor our results to be on the interval [0,100]
                    convertedVal = 0;
                    for g = deg: -1: 0
                        convertedVal = convertedVal + (adjTrainingSet(m,13 + j)^g)*mapCoef(j,g + 1,k);
                    end
                    if convertedVal > 100
                        adjTrainingSet(m,13 + j) = 100;
                    elseif convertedVal < 0
                        adjTrainingSet(m,13 + j) = 0;
                    else
                        adjTrainingSet(m,13 + j) = convertedVal;
                    end
                end
            end
        end
        for m = 1 : 9
            clearvars temp1Error temp2Error;
            testingErrorIndex = 1;
            trainingErrorIndex = 1;
            for j = 1 : size(testingSet,1)
                if testingSet(j,13 + m) >= 0
                    temp1Error(testingErrorIndex) = abs(testingSet(j,13 + m) - adjTestingSet(j,13 + m));
                    testingErrorIndex = testingErrorIndex + 1;
                end
            end
            for j = 1 : size(trainingSet,1)
                if trainingSet(j,13 + m) >= 0
                    temp2Error(trainingErrorIndex) = abs(trainingSet(j,13 + m) - adjTrainingSet(j,13 + m));
                    trainingErrorIndex = trainingErrorIndex + 1;
                end
            end
    
            testingError(m,1) = mean(temp1Error);
            testingError(m,2) = median(temp1Error);
            testingError(m,3) = max(temp1Error);
            trainingError(m,1) = mean(temp2Error);
            trainingError(m,2) = median(temp2Error);
            trainingError(m,3) = max(temp2Error);
        end
        mapErrorTemp(:,:,k) = abs(testingError - trainingError);
        mappedDataTemp = inputData;
        temp = find(usrIndexSet(k,:));
        for j = 1 : size(find(usrIndexSet(k,:)),2)
            for m = 1 : 9
                convertedVal = 0;
                for g = deg: -1: 0
                    convertedVal = convertedVal + (mappedDataTemp(usrIndexSet(k,temp(j)),13 + m)^g)*mapCoef(m,g + 1);
                end
                if convertedVal > 100
                    mappedDataTemp(usrIndexSet(k,temp(j)),13 + m) = 100;
                elseif convertedVal < 0
                    mappedDataTemp(usrIndexSet(k,temp(j)),13 + m) = 0;
                else
                    mappedDataTemp(usrIndexSet(k,temp(j)),13 + m) = convertedVal;
                end
            end
        end
    end
    mapError = mean(mapErrorTemp);
end
mappedData = zeros(size(mappedDataTemp,1),14);
mappedData(:,1:13) = mappedDataTemp(:,1:13);
for k = 1 : size(mappedDataTemp,1)
    clearvars temp
    temp(1) = NaN;
    index = 1;
    for j = 1 : 9
        if mappedDataTemp(k,13 + j) >= 0
           temp(index) = mappedDataTemp(k,13 + j); 
           index = index + 1;
        end
    end
    indexTemp = 1;
    for j = 1 : size(temp,2)
        if ~isnan(temp(j))
            temp2(indexTemp) = temp(j); 
            indexTemp = indexTemp + 1;
        end
    end
    if medianMap
        mappedData(k,14) = median(temp2);
    else
        mappedData(k,14) = mean(temp2);
    end
end

%rescale the mapped values so that they are not centered so closely
%together
minimum = min(mappedData(:,14));
maximum = max(mappedData(:,14));
for k = 1 : size(mappedData,1)
   mappedData(k,14) = (mappedData(k,14) - minimum) / (maximum - minimum);
end

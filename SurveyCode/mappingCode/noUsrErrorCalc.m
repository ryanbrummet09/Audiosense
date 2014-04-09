%Author Ryan Brummet
%University of Iowa

function [ mapError ] = noUsrErrorCalc( trainingSet, testingSet, ...
    mapCoef, deg)

%trainingSet (input matrix): subset of the overall patient data matrix
%       that is used as a training set to map attributes

%testingSet (input matrix): subset of the overall patient data matrix that
%       will is used as a testing set for the attribute mappings

%mapCoef (input matrix): gives the mapping coefficients from an attribute
%       to the target attribute.  Each row correspondes to an attribute
%       where row one is sp, 2 is le, 3 is ld, 4 is ld2, 5 is lcl, 6 is ap,
%       7 is qol, 8 is im, and 9 is st.  The highest degree coefficient is
%       at the highest index (column index).

%deg (input deg): gives the degree of the polynomial that acts as the
%       mapping function

%mapError (output matrix): the training set error minus the testing set error.
%       The error for each set is found by subtracting real values from
%       predicted map values for each attribute.  The median, mean, and max
%       across all samples are recorded for the training and testing sets.
%       Finally the absolute difference between the testing and training
%       set is found.


    adjTrainingSet = trainingSet;
    for k = 1 : size(trainingSet,1)
        for j = 1 : 9
            %we censor our results to be on the interval [0,100]
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
    
    adjTestingSet = testingSet;
    for k = 1 : size(testingSet,1)
        for j = 1 : 9
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
end


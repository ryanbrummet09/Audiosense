%Author Ryan Brummet
%University of Iowa

function [ mapError ] = yesUsrErrorCalc(user, trainingSet, testingSet, ...
    mapCoef, deg)

%user (input int): gives the current user that is being examined.  Needed
%       as one of the indice dimensions of several input variables.

%trainingSet (input 3dArray): subset of the overall patient data matrix
%       that is used as a training set to map attributes

%testingSet (input 3dArray): subset of the overall patient data matrix that
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
    for m = 1 : size(find(trainingSet(:,1,user)),1)
        for j = 1 : size(trainingSet(:,14:size(trainingSet,2)),2)
            %we censor our results to be on the interval [0,100]
            convertedVal = 0;
            for g = deg: -1: 0
                convertedVal = convertedVal + (adjTrainingSet(m,13 + j,user)^g)*mapCoef(j,g + 1,user);
            end
            if convertedVal > 100
                adjTrainingSet(m,13 + j,user) = 100;
            elseif convertedVal < 0
                adjTrainingSet(m,13 + j,user) = 0;
            else
                adjTrainingSet(m,13 + j,user) = convertedVal;
            end
        end
    end

    adjTestingSet = testingSet;
    for m = 1 : size(find(testingSet(:,1,user)),1)
        for j = 1 : size(testingSet(:,14:size(testingSet,2)),2)
            %we censor our results to be on the interval [0,100]
            convertedVal = 0;
            for g = deg: -1: 0
                convertedVal = convertedVal + (testingSet(m,13 + j,user)^g)*mapCoef(j,g + 1,user);
            end
            if convertedVal > 100
                adjTestingSet(m,13 + j,user) = 100;
            elseif convertedVal < 0
                adjTestingSet(m,13 + j,user) = 0;
            else
                adjTestingSet(m,13 + j,user) = convertedVal;
            end
        end
    end
    
    for m = 1 : size(trainingSet(:,14:size(trainingSet,2)),2)
        clearvars temp1Error temp2Error;
        testingErrorIndex = 1;
        trainingErrorIndex = 1;
        temp1Error(1) = NaN;
        temp2Error(1) = NaN;
        for j = 1 : size(find(testingSet(:,1,user)),1)
            if testingSet(j,13 + m,user) >= 0 && testingSet(j,1,user) ~= 0
                temp1Error(testingErrorIndex) = abs(testingSet(j,13 + m,user) - adjTestingSet(j,13 + m,user));
                testingErrorIndex = testingErrorIndex + 1;
            end
        end
        for j = 1 : size(find(trainingSet(:,1,user)),1)
            if trainingSet(j,13 + m,user) >= 0 && trainingSet(j,1,user) ~= 0
                temp2Error(trainingErrorIndex) = abs(trainingSet(j,13 + m,user) - adjTrainingSet(j,13 + m,user));
                trainingErrorIndex = trainingErrorIndex + 1;
            end
        end
    
        if isnan(max(temp1Error))
            testingError(m,1) = NaN;
            testingError(m,2) = NaN;
            testingError(m,3) = NaN;
        else
            testingError(m,1) = mean(temp1Error);
            testingError(m,2) = median(temp1Error);
            testingError(m,3) = max(temp1Error);
        end
        
        if isnan(max(temp2Error))
            trainingError(m,1) = NaN;
            trainingError(m,2) = NaN;
            trainingError(m,3) = NaN;
        else
            trainingError(m,1) = mean(temp2Error);
            trainingError(m,2) = median(temp2Error);
            trainingError(m,3) = max(temp2Error);
        end
        
    end
    mapError = abs(testingError - trainingError);
end


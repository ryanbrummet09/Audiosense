%Author Ryan Brummet
%University of Iowa

function [ returnData ] = combineScoresAndReScale( inputData, mapType )
    %inputData (input matrix): patient data with all attributes mapped onto
    %one attribute
    
    %mapType (input bool): if true scores are combined using median score.
    %if false scores are combined using mean score.
    
    %returnData (output matrix): gives a matrix with a single combined
    %attribute score
    
    returnData = zeros(size(inputData,1),14);
    returnData(:,1:13) = inputData(:,1:13);
    for k = 1 : size(inputData,1)
        clearvars temp
        temp(1) = NaN;
        index = 1;
        for j = 1 : 9
            if inputData(k,13 + j) >= 0
                temp(index) = inputData(k,13 + j); 
                index = index + 1;
            end
        end
        if isnan(temp(1))
            k
            error('penis'); 
        end
        if mapType
            returnData(k,14) = median(temp);
        else
            returnData(k,14) = mean(temp);
        end
    end
    %rescale the mapped values so that they are not centered so closely
    %together
    minimum = min(returnData(:,14));
    maximum = max(returnData(:,14));
    for k = 1 : size(returnData,1)
        returnData(k,14) = 100 * (returnData(k,14) - minimum) / (maximum - minimum);
    end
end


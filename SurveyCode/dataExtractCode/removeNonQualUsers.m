%Author Ryan Brummet
%University of Iowa

function [ returnedData, userSet, userSampleCount, userIndexSet ] = ...
    removeNonQualUsers( inputData, userSet, userSampleCount, userIndexSet)
    
%Removes all samples for user that have less than 20 samples.  This is done
%for two reasons.  First, to prevent innaccuracies from being created
%during normalization.  Second, to prevent rare features from being
%magnified to appear to be frequently occuring.  Also updates userSet

%inputData (input matrix): patient Data

%userSet (input vector): vector of unique patient id's

%userSampleCount (input
    index = 1;
    for k = 1 : size(userSampleCount,1)
        if userSampleCount(k,2) < 20
            temp(index) = userSampleCount(k,1);
            index = index + 1;
        end
    end
    index = 1;
    clearvars userIndexSet userSampleCount
    
    index = 1;
    for k = 1 : size(userSet,2)
        if ismember(userSet(k), temp)
            temp3(index) = k;
            index = index + 1;
        end
    end
    userSet(temp3) = [];
    userSampleCount = zeros(size(userSet,2),2);
    userSampleCount(:,1) = userSet;
    
    index = 1;
    for k = 1 : size(inputData,1)
        if ~ismember(inputData(k,1),temp) 
            temp2 = find(userSampleCount(:,1) == inputData(k,1));
            userSampleCount(temp2,2) = userSampleCount(temp2,2) + 1;
            userIndexSet(temp2,userSampleCount(temp2,2)) = index;
            returnedData(index,:) = inputData(k,:); 
            index = index + 1;
        end
    end
end


%Author Ryan Brummet
%University of Iowa

function [ returnData ] = normalizeDataGlobally( inputData )
%inputData (input matrix): input patient data

%returnedData (output matrix): output normalized patient data

    %we look at each attribute individually, whether than all at the same
    %time, becuase the set includes zeros.  The number of good values that
    %we get for each attribute are different becuase of NaN values, but we
    %can't use find to eliminate "overflow" since the values include 0.
    norms = zeros(9,2);
    for k = 1 : 9
        index = 1;
        for j = 1 : size(inputData,1)
             if input(j,13 + j) >= 0
                 temp(index) = input(j,13 + j);
                 index = index + 1;
             end
        end
        norms(k,1) = mean(temp);
        norms(k,2) = std(temp);
        clearvars temp);
    end
    
    %normalize data
    returnData = inputData;
    for k = 1 : size(inputData,1)
        for j = 1 : 9
            returnData(k,13 + j) = (inputData(k,13 + j) - norms(j,1)) / norms(j,2); 
        end
    end
    
    %rescale data to be on the interval [0,100]
    %minimum and maximums are found per attribute and not globally for all
    %attributes
    for k = 1 : 9
        minimum(k) = min(returnData(:,13 + k));
        maximum(k) = max(returnData(:,13 + k));
    end
    
    for k = 1 : size(returnData,1)
        for j = 1 : 9
            returnData(k,13 + j) = 100 * (returnData(k,13 + j) - minimum(j)) / (maximum(j) - minimum(j));
        end
    end
end


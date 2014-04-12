%Author Ryan Brummet
%University of Iowa

function [ pValue ] = getPValueUsingTTestAndSingleScore( groupOne, ...
    groupTwo)
%Finds the t value for the combined score between two groups.  This t
%value is then converted to a pValue.  The p value gives the probabiliy
%that the two groups were sampled from two different populations.

% groupOne (input matrix): subset of patient data

% groupTwo (input matrix): patient data set minus groupOne

% pValues (output vector): p values between each group attribute


    %group one average and standard deviation calc
    avgSTDContexts = zeros([2,19]);
    avgSTDContexts(1,1) = 1;
    avgSTDContexts(2,1) = 2;
    index = 1;
    temp(1) = NaN;
    for i = 1 : size(groupOne,1)
        if groupOne(i,14) >= 0
            temp(index) = groupOne(i,14);
            index = index + 1;
        end
    end
    avgSTDContexts(1,2) = mean(temp);
    avgSTDContexts(1,3) = std(temp);
    clearvars temp;
    
    %group two average and standard deviation calc
    index = 1;
    temp(1) = NaN;
    for i = 1 : size(groupTwo,1)
        if groupTwo(i,14) >= 0
            temp(index) = groupTwo(i,14);
            index = index + 1;
        end
    end
    avgSTDContexts(2,2) = mean(temp);
    avgSTDContexts(2,3) = std(temp);
    clearvars temp;
    
    %the t value will be placed into the tValues array row 1, column 1. df
    %df will be placed in row 2, column 1.  Notice that we are assumming that the 
    %variance of the combined score between the two groups is not the same.  We 
    %have modified our t test to account for this.  We also account for the 
    %possiblity that the sizes of group one and group two are different.
    n1 = size(groupOne,1);
    n2 = size(groupTwo,1);
    stDevOne = avgSTDContexts(1,((2 * 1) + 1));
    stDevTwo = avgSTDContexts(2,((2 * 1) + 1));
    avgOne = avgSTDContexts(1,(1 * 2));
    avgTwo = avgSTDContexts(2,(1 * 2));
    tValues(1,1) = (avgOne - avgTwo) / ((((stDevOne^2) / (n1)) + ((stDevTwo^2) / (n2)))^(1/2));
    if n1 == n2
        tValues(2,1) = 2 * (n1 - 1);
    else
        tValues(2,1) = ((((stDevOne^2)/n1) + ((stDevTwo^2)/n2))^2) / (((((stDevOne^2)/n1)^2) / (n1 - 1)) + ((((stDevTwo^2)/n2)^2) / (n2 - 1)));
    end
    
    %calculate pValue
    pValue = tcdf(tValues(1,k),tValues(2,k));  
end


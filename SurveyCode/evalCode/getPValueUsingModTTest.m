%Author Ryan Brummet
%University of Iowa

function [ pValues ] = getPValueUsingModTTest( groupOne, groupTwo )
%finds the t values for each attribute between two groups.  These t values
%are then converted to p values.  p values give the probability that the
%two groups were sampled from two different populations.

% groupOne (input matrix): subset of patient data

% groupTwo (input matrix): patient data set minus groupOne

% pValues (output vector): p values between each group attribute


    %group one average and standard deviation calc
    avgSTDContexts = zeros([2,19]);
    avgSTDContexts(1,1) = 1;
    avgSTDContexts(2,1) = 2;
    for k = 1 : 9
        index = 1;
        temp(1) = NaN;
        for i = 1 : size(groupOne,1)
            if groupOne(i,(14 + k - 1)) >= 0
                temp(index) = groupOne(i,(14 + k - 1));
                index = index + 1;
            end
        end
        avgSTDContexts(1,(k * 2)) = mean(temp);
        avgSTDContexts(1,((k * 2) + 1)) = std(temp);
        clearvars temp;
    end
    
    %group two average and standard deviation calc
    for k = 1 : 9
        index = 1;
        temp(1) = NaN;
        for i = 1 : size(groupTwo,1)
            if groupTwo(i,(14 + k - 1)) >= 0
                temp(index) = groupTwo(i,(14 + k - 1));
                index = index + 1;
            end
        end
        avgSTDContexts(2,(k * 2)) = mean(temp);
        avgSTDContexts(2,((k * 2) + 1)) = std(temp);
        clearvars temp;
    end
    
    %t values will be placed in the tValues array and will be ordered by
    %the subjective attributes sp, le, ld, ld2, lcl, ap, qol, im, st in the 
    %first row and df in second.  Notice that we are assumming that the 
    %variance of an attribute between the two groups is not the same.  We 
    %have modified our t test to account for this.  We also account for the 
    %possiblity that the sizes of group one and group two are different.
    n1 = size(groupOne,1);
    n2 = size(groupTwo,1);
    for k = 1 : 9
        stDevOne = avgSTDContexts(1,((2 * k) + 1));
        stDevTwo = avgSTDContexts(2,((2 * k) + 1));
        avgOne = avgSTDContexts(1,(k * 2));
        avgTwo = avgSTDContexts(2,(k * 2));
        tValues(1,k) = (avgOne - avgTwo) / ((((stDevOne^2) / (n1)) + ((stDevTwo^2) / (n2)))^(1/2));
        if n1 == n2
            tValues(2,k) = 2 * (n1 - 1);
        else
            tValues(2,k) = ((((stDevOne^2)/n1) + ((stDevTwo^2)/n2))^2) / (((((stDevOne^2)/n1)^2) / (n1 - 1)) + ((((stDevTwo^2)/n2)^2) / (n2 - 1)));
        end
    end
    
    %calculate pValues, stored in pValues with the same ordering as the 
    %first row of tValues (by column)
    for k = 1 : 9
        pValues(k) = tcdf(tValues(1,k),tValues(2,k)); 
    end
end


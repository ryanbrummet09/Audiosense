function [pValues] = getPValueUsingTTestAndSingleScore(groupOne,groupTwo)

clearvars temp;
%group one average and standard deviation calc
avgSTDContexts = zeros([1,19]);
avgSTDContexts(1,1) = 1;
avgSTDContexts(2,1) = 2;
index = 1;
test = false;
for i = 1 : size(groupOne,1)
    if groupOne(i,14) >= 0
        temp(index) = groupOne(i,14);
        index = index + 1;
        test = true;
    end
end
if test
    avgSTDContexts(1,2) = mean(temp);
    avgSTDContexts(1,3) = std(temp);
end

%group two average and standard deviation calc
clearvars temp;
index = 1;
test = false;
for i = 1 : size(groupTwo,1)
    if groupTwo(i,14) >= 0
        temp(index) = groupTwo(i,14);
        index = index + 1;
        test = true;
    end
end
if test
    avgSTDContexts(2,2) = mean(temp);
    avgSTDContexts(2,3) = std(temp);
end

%t values will be placed in the tValues array and will be ordered for the t
%values for comparisons of the subjective attributes sp, le, ld, ld2, lcl,
%ap, qol, im, st in the first row and df in second.  Notice that we are assumming that the variance of an
%attribute between the two groups is not the same.  We have modified our t
%test to account for this.  We also account for the possiblity that the
%sizes of group one and group two are different.  Our null hypothesis will
%always be that two attributes are similar (m1 - m2 = 0).  We will use the two-tailed
%test.  Therefore t values close to zero indicate that the two groups are
%similar and t values far from zero indicate that the two groups are
%different.
n1 = size(groupOne,1);
n2 = size(groupTwo,1);
for k = 1 : 1
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

%calculate pValues, stored in pValues with the same ordering as the tValues
%matrix (by column)
pValues = tcdf(tValues(1,k),tValues(2,k)); 
return;

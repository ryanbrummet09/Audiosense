function [ toBeNormalized ] = normValues( toBeNormalized, ...
                              numberOfLabels )
%NORMVALUES normalize values
%   Normalizes the values of the input toBeNormalized, removes the rows
%   which contain NaN or Inf. The number of labels is an optional field but
%   indicates how many columns from to the end to ignore if there are any
%   labels present.
if 1 == nargin
    numberOfLabels = 0;
end
[r,c] = size(toBeNormalized);
toKeepOverall = true(r,1);
for P=5:c-numberOfLabels
    temp = toBeNormalized(:,P);
    isNanOrIsInf = find(isnan(temp) | isinf(temp));
    nIsNanOrIsInf = find(~isnan(temp) & ~isinf(temp));
    toKeepOverall(isNanOrIsInf) = false;
    temp_mean = mean(temp(nIsNanOrIsInf));
    temp_std = std(temp(nIsNanOrIsInf));
    temp(nIsNanOrIsInf) = (temp(nIsNanOrIsInf) - temp_mean)/temp_std;
    toBeNormalized(:,P) = temp;
end
toBeNormalized = toBeNormalized(toKeepOverall,:);
[rd,cd] = size(toBeNormalized);
disp(sprintf('No. of rows removed for being nan or inf:%d, out of %d'...
             ,r-rd,r));
end


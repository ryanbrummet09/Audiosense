function [ opArray ] = robustMean( ipArray )
%ROBUSTMEAN mean function that removes nan's and inf's

[r,c] = size(ipArray);
opArray = zeros(1,c);
for P=1:c
    temp = ipArray(:,P);
    toKeep = true(r,1);
    nanidx = find(isnan(temp));
    infidx = find(isinf(temp));
    toKeep(nanidx) = false;
    toKeep(infidx) = false;
    opArray(1,P) = mean(temp(toKeep));
end

end


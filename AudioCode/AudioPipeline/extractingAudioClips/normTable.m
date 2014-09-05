function [ featureTable ] = normTable( featureTable )
%NORMTABLE normalize all the features
%   take the z transform individually on each column

varNames = featureTable.Properties.VariableNames;
n = length(varNames);
for P=5:n-1
    varN = varNames{P};
    val = eval(sprintf('featureTable.%s;',varN));
    val_mean = mean(val);
    val_std = std(val);
    val = (val - val_mean)/val_std;
    eval(sprintf('featureTable.%s = val;',varN));
end

end


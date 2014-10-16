function [ featureTable ] = normTable( featureTable )
%NORMTABLE normalize all the features
%

varNames = featureTable.Properties.VariableNames;
n = length(varNames);
for P=4:n-1
    varN = varNames{P};
    val = eval(sprintf('featureTable.%s;',varN));
    ninf = find(~isinf(val) & ~isnan(val));
    iinf = find(isinf(val) | isnan(val));
    val_mean = mean(val(ninf));
    val_std = std(val(ninf));
    val(ninf) = (val(ninf) - val_mean)/val_std;
    val(iinf) = 0;
    eval(sprintf('featureTable.%s = val;',varN));
end

end


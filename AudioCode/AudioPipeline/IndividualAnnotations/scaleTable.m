function [ featureTable ] = scaleTable( featureTable )
%SCALETABLE Scales the table between 0 and 1
%   Detailed explanation goes here
varNames = featureTable.Properties.VariableNames;
n = length(varNames);
for P=4:n-1
    varN = varNames{P};
    val = eval(sprintf('featureTable.%s;',varN));
    ninf = find(~isinf(val) & ~isnan(val));
    iinf = find(isinf(val) | isnan(val));
    val_min = min(val(ninf));
    val_max = max(val(ninf));
    val = (val-val_min)/(val_max-val_min);
    val(iinf) = 0;
    eval(sprintf('featureTable.%s = val;',varN));
end

end


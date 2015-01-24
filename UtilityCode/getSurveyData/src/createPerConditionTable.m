function [ perConditionStruct ] = createPerConditionTable( ipDataset, ...
                                    minSamples, conditionsToLookAt )
%CREATEPERCONDITIONTABLE Create per condition tables
%   Input:
%           ipDataset           :   Table to be worked upon
%           minSamples          :   Minimum number of samples that a
%                                   condition should have to be included in
%                                   the output, default = 10
%           conditionsToLookAt  :   Conditions to include in the final 
%                                   output
%   
%   Output:
%           perConditionStruct  :   Structure containing per condition data
%                                   each condition is identified by
%                                   patient_<conditionID> field

if 1 == nargin
    minSamples = 10;
    conditionsToLookAt = unique(ipDataset.condition);
elseif 2 == nargin
    conditionsToLookAt = unique(ipDataset.condition);
end

perConditionStruct = struct;

for P=1:length(conditionsToLookAt)
    pTable = ipDataset(ipDataset.condition == conditionsToLookAt(P),:);
    if minSamples > height(pTable)
        disp(sprintf('Condition %d has %d samples, removing', ...
                conditionsToLookAt(P), height(pTable)));
        continue;
    else
        perConditionStruct.(sprintf('condition_%d',conditionsToLookAt(P)))= ...
                                pTable;
    end
end


end


function [ combinedF ] = combineFields( ipDataset, groupVars )
%COMBINEFIELDS Combine fields for stratification
%   Input:
%           ipDataset   :   dataset from which grouping variables are taken
%           groupVars   :   field names of grouping variables
% 
%   Output:
%           combinedF   :   combined fields in a single string, separated
%                           by _
% 
% 


n = length(groupVars);

if 1 > n
    error('At least 1 grouping variable is needed');
    return;
end
l1 = length(ipDataset.(groupVars{1}));
combinedF = cell(l1, 1);
for P=1:l1
    toPut = '';
    for Q = 1:n
        temp = ipDataset.(groupVars{Q});
        if 1 == Q
            toPut = strcat(toPut, num2str(temp(P)));
        else
            toPut = strcat(toPut, '_', num2str(temp(P)));
        end
    end
    combinedF{P} = toPut;
end

end


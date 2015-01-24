function [ paritionsCV ] = stratifyByPreds( ipDataset, groupVars, ...
                            numOfFolds )
%STRATIFYBYPREDS Stratify input dataset using grouping variables
%   Input:
%           ipDataset       :       dataset from which grouping variables
%                                   are selected
%           groupVars       :       field names of grouping variables
%           numOfFolds      :       number of folds for the partitioning of
%                                   data
% 
%   Output:
%           partitionCV     :       fold information generated using
%                                   CVPARTITION
% 
%   SEE ALSO COMBINEFIELDS

combinedFields = combineFields(ipDataset, groupVars);
paritionsCV = cvpartition(combinedFields, 'kfold', numOfFolds);

end


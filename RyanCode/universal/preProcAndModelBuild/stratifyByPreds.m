% Ryan Brummet
% University of Iowa
%
% Takes as input a table and statifies it into a specified number of folds
% using the input grouping variables.  This function is designed to only
% work for data from our group's audiology project.  It may work for other
% data sets as long as each input variable is described as a categorical
% variable on the interval [0,9] and contains no NaN values.
%
% Params:
%   table: dataTable - input data with appropriately named columns
%   cell array: groupVars - list of variable names to be used to stratify 
%                           dataTable
%   int: crossValFolds - gives the number of groups to stratify dataTable
%                        into
%
% Return:
%   cvpartition: returnCV - gives cvpartition object to be used for
%                           stratification

function [ returnCV ] = stratifyByPreds( dataTable, groupVars, crossValFolds )
    cvVar = zeros(size(dataTable,1),1);
    testCND = false;
    if ismember('condition',groupVars)
        groupVars(ismember(groupVars,'condition')) = [];
        testCND = true;
    end
    for cs = 0 : size(groupVars,2) - 1
        if strcmp(char(groupVars{cs + 1}),'patient')
            cvVar = cvVar + dataTable.patient;
        else
            cvVar = cvVar + dataTable.(groupVars{cs + 1}) * 10 ^ (-cs);
        end
    end
    if testCND
        cvVar = cvVar + dataTable.condition * 10 ^ (-cs - 2);
    end
    dataTable.cvVar = cvVar;
    returnCV = cvpartition(dataTable.cvVar,'kfold',crossValFolds);
    dataTable.cvVar = [];
end


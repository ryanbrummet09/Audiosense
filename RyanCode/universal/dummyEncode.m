% Ryan Brummet
% University of Iowa
%
% takes as input a table, dummy encodes categorical variables, replaces
% the original variables, appends the numerical variables, and returns the
% resulting matrix
%
% Params:
%   table: dataTable - the input data in the form of a table
%   cell array: surveyPreds - gives the names of the categorical variables
%                             in the table.
%   cell array: zeroPreds - gives the names of variables in surveyPreds
%                           that contain 0 as a categorical option.

function [ targetData ] = dummyEncode( dataTable, surveyPreds, zeroPreds )
    tableNames = dataTable.Properties.VariableNames;
    index = 1;
    for k = 1 : size(surveyPreds,2)
        if ismember(surveyPreds{index},tableNames)
            if index == 1
                if ismember(surveyPreds{index},zeroPreds)
                    dummyVars = dummyvar(dataTable.(surveyPreds{index}) + 1);
                    dummyVars = dummyVars(:,2:end);
                else
                    dummyVars = dummyvar(dataTable.(surveyPreds{index}));
                end
            else
                if ismember(surveyPreds{index},zeroPreds)
                    temp = dummyvar(dataTable.(surveyPreds{index}) + 1);
                    dummyVars = [dummyVars,temp(:,2:end)];
                else
                    dummyVars = [dummyVars,dummyvar(dataTable.(surveyPreds{index}))];
                end
            end
            index = index + 1;
        else
            surveyPreds(index) = [];
        end
    end
    dummyVars(:,sum(dummyVars,1) == 0) = [];
    dataTableTemp = dataTable;
    dataTableTemp(:,surveyPreds) = [];
    targetData = [dummyVars, table2array(dataTableTemp)];
end


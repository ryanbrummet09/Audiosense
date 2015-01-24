function [ demographicTable ] = getDemographicsData( xlsFilePath )
%GETDEMOGRAPHICSDATA Extract the demographic data
%   Input:
%           xlsFilePath         :       Path to the xls(x) file containing
%                                       the demographics data in the sheet
%                                       'Demographics'
% 
%   Output:
%           demographicTable    :       A two field table, with patient and
%                                       age
% 


demoDataAge = xlsread(xlsFilePath, 'Demographics');
demoDataAge(:,3:end) = [];
demoDataAge = demoDataAge(~isnan(demoDataAge(:,1)) & ...
                ~isnan(demoDataAge(:,2)),:);
demographicTable = array2table(demoDataAge);
demographicTable.Properties.VariableNames = {'patient', 'age'};

end


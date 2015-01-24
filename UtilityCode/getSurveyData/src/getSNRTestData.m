function [ sinTestTable ] = getSNRTestData( xlsFilePath )
%GETSNRTESTDATA Extract SIN Test information
%   Input:
%           xlsFilePath         :       Path to the xls(x) file containing
%                                       the demographics data in the sheet
%                                       'QuickSin'
% 
%   Output:
%           sinTestTable        :       A three field table with patient
%                                       id, SNR loss for right ear, and SNR
%                                       loss for left ear
% 
%   SEE ALSO XLSREAD, ARRAY2TABLE

sinTestData = xlsread(xlsFilePath, 'QuickSin');
sinTestData = sinTestData(:, [1,4,8]);
sinTestData = sinTestData(~isnan(sinTestData(:,1)) & ...
                ~isnan(sinTestData(:,2)) & ...
                ~isnan(sinTestData(:,3)),:);
sinTestTable = array2table(sinTestData);
sinTestTable.Properties.VariableNames = {'patient', 'sinRight', 'sinLeft'};
end


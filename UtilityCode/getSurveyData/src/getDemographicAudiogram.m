function [ audiogramTable ] = getDemographicAudiogram( xlsFilePath )
%GETDEMOGRAPHICAUDIOGRAM extract the summary of audiogram data
%   Input:
%           xlsFilePath         :       Path to the xls(x) file containing
%                                       the demographics data in the sheet
%                                       'Audiogram'
% 
%   Output:
%           audiogramTable      :       five field table with fields for
%                                       patient id, low frequency and high
%                                       frequency PTAs for the left and the
%                                       right ears
% 
%   SEE ALSO XLSREAD, ARRAY2TABLE

[xlsVals, textVals, rawVals] = xlsread(xlsFilePath, 'Audiogram');
xlsVals = xlsVals(2:end-2,:);
textVals = textVals(2:end-2,:);
rawVals = rawVals(2:end-2,:);
rightPids = rawVals(:,1);
leftPids = rawVals(:,14);
leftPids = regexp(leftPids, '\d+', 'match');
rightPids = regexp(rightPids, '\d+', 'match');
if 0 ~= sum(~isequal(leftPids, rightPids))
    error('The patient ids are not the same in some row of Audiogram');
end
pids = [];
lowFLeft = [];
lowFRight = [];
highFLeft = [];
highFRight = [];
toKeep = true(length(leftPids),1);
for P=1:length(leftPids)
    temp = leftPids{P};
    pids(P,1) = str2num(temp{1});
    lowFRight(P,1) = mean(xlsVals(P,[2,3,4]));
    lowFLeft(P,1) = mean(xlsVals(P,[15,16,17]));
    highFRight(P,1) = mean(xlsVals(P,[3,4,6]));
    highFLeft(P,1) = mean(xlsVals(P,[16,17,19]));
    if isnan(lowFLeft(P,1)) | isnan(lowFRight(P,1)) | ...
            isnan(highFLeft(P,1)) | isnan(highFRight(P,1))
        toKeep(P,1) = false;
    end
end
finalMatrix = [pids, lowFLeft, highFLeft, lowFRight, highFRight];
finalMatrix = finalMatrix(toKeep,:);
audiogramTable = array2table(finalMatrix);
audiogramTable.Properties.VariableNames = {'patient', 'lowPTALeft', ...
    'highPTALeft', 'lowPTARight', 'highPTARight'};
end


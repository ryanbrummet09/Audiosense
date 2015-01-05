% Ryan Brummet
% University of Iowa

% extracts survey data from .survey files.  Also maintains audio feature
% and survey pairing.

close all;
clear;
clc;

%% Define Variable Params.  Nothing should be changed outside this section

% give path to all files in AudioStuff directory
addpath(genpath('/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff'));

% give location of .mat file containing audio feature and survey data pairs
pairFileName = 'audioSurveyPairs.mat';

% gives the list of features that will be extracted.  patient, start-time,
% end-time, user-initiated, listening, and sp, le, ld, ld2, lcl, ap, qol,
% im, st, and condition MUST BE PRESENT
featureList = {'patient','start-time','end-time','user-initiated','listening','ac','lc', ...
    'tf','vc','tl','nz','nl','rs','cp','condition','sp','le','ld','ld2','lcl','ap','qol','im','st'};

% gives the names of the extracted features as they will appear in the
% dataTable variable
featureListNames = {'patient','startTime','endTime','userInitiated', ...
    'listening','ac','lc','tf','vc','tl','nz','nl','rs','cp', ...
    'condition','sp','le','ld','ld2','lcl','ap','qol','im','st'};

% gives the list of features that will be stored as cells in the dataTable
% variable.  Named according to how they appear in the raw data files.
cellFeatureList = {'start-time','end-time','user-initiated','listening'};

% gives the list of features that must be converted to numeric and
% incremented by one.  Named according to how they appear in the raw data
% files.
incrementFeatureList = {'user-initiated','listening'};

% fifty remove date. In year, month, date, hour, min, sec format
fiftyRemoveDate = [2014, 1, 30, 0, 0, 0];

% gives the values used to predict responses using the surveys that might
% be NaN
nanPredictors = {'tf','vc','tl','nl','rs','cp'};

% gives the values to check for 50s.  All values given here must appear in
% featureListNames
responses = {'sp','le','ld','ld2','lcl','ap','qol','im','st'};

% a user not having this # of samples has all samples removed
minNumSamplesPerUser = 10;

% tests for [NaN] in cells
Fx = @(x) any(isnan(x));

%%  Create survey data table with linked audio features

% load survey and audio pair paths
load(pairFileName);

% build variable to store survey data and audio feature location
dataTable = array2table(NaN(size(audioSurveyPairs,1),size(featureList,2) + 1));
dataTable.Properties.VariableNames = [featureListNames, {'featureLocation'}];

% convert necessary table columns to cell
for k = 1 : size(cellFeatureList,2)
   index = strcmp(cellFeatureList{k},featureList);
   dataTable.(featureListNames{index}) = num2cell(dataTable.(featureListNames{index}));
end
dataTable.featureLocation = num2cell(dataTable.featureLocation);

% extract data from survey files and store in dataTable
for k = 1 : size(audioSurveyPairs,1)
    fid = fopen(audioSurveyPairs.SurveyLocation{k});
    currentLine = fgetl(fid);
    while ischar(currentLine)
        currentLine = strsplit(currentLine,'=');
        varTest = find(strcmp(currentLine{1},featureList) == 1);
        cellTest = find(strcmp(currentLine{1},cellFeatureList) == 1);
        if varTest > 0
            if cellTest > 0
                dataTable.(featureListNames{varTest}){k} = currentLine{2};
            else
                if strcmp(currentLine{1},'patient')
                    temp = currentLine{2};
                    dataTable.(featureListNames{varTest})(k) = str2double(temp(4:5));
                else
                    dataTable.(featureListNames{varTest})(k) = str2double(currentLine{2});
                end
            end
        end
        varTest = 0;
        cellTest = 0;
        currentLine = fgetl(fid);
    end
    temp = strsplit(audioSurveyPairs.AudioFeatureLocation{k},{'_'});
    if isnan(str2double(temp(3)))
        dataTable.condition(k) = str2double(temp{3}(2));
    else
        dataTable.condition(k) = str2double(temp(3));
    end
    dataTable.featureLocation{k} = audioSurveyPairs.AudioFeatureLocation{k};
    fclose(fid);
    disp(k);
end

%remove samples where all attributes are NaN
toBeRemoved = zeros(size(dataTable,1),1);
for k = 1 : size(responses,2)
    toBeRemoved = isnan(dataTable.(responses{k})) + toBeRemoved;
end
dataTable = dataTable(toBeRemoved < size(responses,2),:);

% uses deprecated function.  Essentially converts startTime to unix
[dataTable] = findSamplesMeetingDurationReq(dataTable);

% remove surveys with 50 response values occuring before fiftyRemoveDate
% fiftyCorrectionDate = getUnixTime(fiftyRemoveDate(1),fiftyRemoveDate(2), ...
% fiftyRemoveDate(3),fiftyRemoveDate(4),fiftyRemoveDate(5),fiftyRemoveDate(6));
% for k = 1 : size(responses,2)
%     dataTable((dataTable.(responses{k}) == 50) & (dataTable.timestamp < fiftyCorrectionDate),:) = [];
% end

%remove samples with users with an insufficient number of samples
[dataTable] = removeNonQualUsers(dataTable,minNumSamplesPerUser);

% reasign attr values so that large values are 'good' and small values are
%'bad'.
dataTable.le = 100 - dataTable.le;
dataTable.ap = 100 - dataTable.ap;

%re-assign duplicate condition values
conditionVals = dataTable.condition;
for k = 1 : size(conditionVals,1)
    if conditionVals(k,1) == 6
        conditionVals(k,1) = 5;
    elseif conditionVals(k,1) == 21
        conditionVals(k,1) = 1;
    elseif conditionVals(k,1) == 22
        conditionVals(k,1) = 2;
    elseif conditionVals(k,1) == 23
        conditionVals(k,1) = 3;
    elseif conditionVals(k,1) == 24
        conditionVals(k,1) = 4;
        
    %we recode condition99 as condition0 so that it will be treated as the
    %reference variable after dummy encoding by the built in matlab code
    elseif conditionVals(k,1) == 99
        conditionVals(k,1) = 0; 
    end
end
dataTable.condition = conditionVals;

%convert user-initiated and listening to numeric
x = cellfun(Fx,dataTable.listening);
dataTable.listening(x) = {'NaN'};
dataTable.listening = str2num(char(dataTable.listening)) + 1;
x = cellfun(Fx,dataTable.userInitiated);
dataTable.userInitiated(x) = {'NaN'};
dataTable.userInitiated = str2num(char(dataTable.userInitiated)) + 1;

%convert predictor NaN values to 0
for k = 1 : size(nanPredictors,2)
    temp = dataTable.(nanPredictors{k});
    temp(isnan(temp)) = 0;
    dataTable.(nanPredictors{k}) = temp;
end
dataTable.listening(isnan(dataTable.listening)) = 0;

save('processedData','dataTable');

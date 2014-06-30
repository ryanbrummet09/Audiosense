%Ryan Brummet
%University of Iowa

%% initialize
clearvars;
close all;
warning('off', 'all');

dataFileName = 'DataTable.mat';  %must be .mat file, variable must be 'unProcessedData'
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;   %a user not having this # of samples has all samples removed
minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]

groupVars = {'ac', 'lc', 'nz', 'patient'};  %used to build a composite variable that is used to statify in cross validation
randomizeDataSampleOrder = true;

%% global variables
attributes = {'sp', 'le', 'ld', 'ld2', 'lcl', 'ap','qol','im', 'st'};
contexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
miscDataInfo = {'patient', 'listening', 'userinitiated', 'hau',};
extractedColNames = [miscDataInfo contexts attributes];

%% preprocess data and make directories
load(dataFileName);

%remove samples where user is listening
if omitListening
    unProcessedData = unProcessedData(~strcmp(unProcessedData.listening,'true'),:);
end

%remove samples where user isn't listening
if omitNotListening
    unProcessedData = unProcessedData(~strcmp(unProcessedData.listening,'false'),:);
end

%remove samples where user initiated survey
if omitUserInit
    unProcessedData = unProcessedData(~strcmp(unProcessedData.userinitiated,'true'),:);
end

%remove samples where user didn't initiate survey
if omitNotUserInit
    unProcessedData = unProcessedData(~strcmp(unProcessedData.userinitiated,'false'),:);
end

%remove samples where user is wearing hearing aid
if omitWearingHearingAid
    unProcessedData = unProcessedData(~strcmp(unProcessedData.hau,'true'),:);
end

%remove samples where user isn't wearing hearing aid
if omitNotWearingHearingAid
    unProcessedData = unProcessedData(~strcmp(unProcessedData.hau,'false'),:);
end

%remove samples that don't make duration requirements and add unix
%timestamp to table
[unProcessedData] = findSamplesMeetingDurationReq(unProcessedData,minPercentOfDurationFromMean);

%remove fifty values
if removeFifties
    fiftyCorrectionDate = getUnixTime(2014,1,30,0,0,0);
    for k = 1 : size(attributes,2)
         unProcessedData.(attributes{k})((unProcessedData.(attributes{k}) == 50) ...
             & unProcessedData.timestamp < fiftyCorrectionDate) = NaN;
    end
end

%remove samples where all attributes are NaN
toBeRemoved = zeros(size(unProcessedData,1),1);
for k = 1 : size(attributes,2)
    toBeRemoved = isnan(unProcessedData.(attributes{k})) + toBeRemoved;
end
unProcessedData = unProcessedData(toBeRemoved < size(attributes,2),:);

%remove samples with users with an insufficient number of samples
[unProcessedData] = removeNonQualUsers(unProcessedData,minNumSamplesPerUser);

%randomize the row order of the matrix
if randomizeDataSampleOrder
    unProcessedData = unProcessedData(randperm(size(unProcessedData,1)),:);
end

%extract relevant columns
processedData = unProcessedData(:,extractedColNames);

%re-assign duplicate condition values
conditionVals = processedData.condition;
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
    end
end
processedData.condition = conditionVals;

%convert true false cells to num
processedData.hau(strcmp(processedData.hau,''),1) = {'NaN'};
processedData.hau = str2num(char(processedData.hau)) + 1;
processedData.listening(strcmp(processedData.listening,''),1) = {'NaN'};
processedData.listening = str2num(char(processedData.listening)) + 1;
processedData.userinitiated(strcmp(processedData.userinitiated,''),1) = {'NaN'};
processedData.userinitiated = str2num(char(processedData.userinitiated)) + 1;

%% Create grouping variable and partition data set
%first create cvVar, a combined variable consisting of several context
%variables.  This is used to give a even distribution of contexts per fold
cvVar = zeros(size(processedData,1),1);
for gv = 1 : size(groupVars,2)
    if strcmp(char(groupVars{gv}),'patient')
        cvVar = cvVar + processedData.patient;
    else
        cvVar = cvVar + processedData.(groupVars{gv}) * 10 ^ (-gv);
    end
end
processedData.cvVar = cvVar;

cv = cvpartition(processedData.cvVar,'kfold',5);

%% Normalize By user
trainingSetTemp = processedData(training(cv,1),:);

%find unique users
subjectIDs = unique(processedData.patient);
        
%iterate through each patient
for s = 1 : size(subjectIDs,1)
            
    %find user samples in training set
    subjectTrainingSamples = (trainingSetTemp.patient == subjectIDs(s));
            
    %find user samples in the whole data set
    subjectSamples = (processedData.patient == subjectIDs(s));
            
    %for each patient, iterate through each attribute and find the
    %norm values (avg and std of samples in training set)
    for k = 1 : size(attributes,2)
        AVG(s,k) = nanmean(table2array(trainingSetTemp(subjectTrainingSamples,attributes{k})));
        STD(s,k) = nanstd(table2array(trainingSetTemp(subjectTrainingSamples,attributes{k})));
                
        %apply normalization values to attributes in subject
        %samples in training and testing sets
        processedData(subjectSamples,attributes{k}) = ...
            array2table((table2array(processedData(subjectSamples,attributes{k})) - AVG(s,k)) / STD(s,k));
    end
end

for attr = 1 : size(attributes,2)
    %assign inf values to nan
    if size(processedData(isinf(table2array(processedData(:,attributes{attr}))),attributes{attr}),1) ~= 0
        temp = size(processedData(isinf(table2array(processedData(:,attributes{attr}))),attributes{attr}),1);
        processedData(isinf(table2array(processedData(:,attributes{attr}))),attributes{attr}).(attributes{attr}) = NaN(temp,1);
    end
        
    processedData.(attributes{attr}) = 100 * (processedData.(attributes{attr}) - ...
        nanmin(processedData.(attributes{attr}))) / (nanmax(processedData.(attributes{attr})) - ...
        nanmin(processedData.(attributes{attr}))); 
end

%% Produce Combined Score
score = zeros(size(processedData,1),1);
for k = 1 : size(attributes,2)
    score = nansum([score, processedData.(attributes{k})],2);
    processedData.(attributes{k}) = [];
end
processedData.score = score;

%% Assign Training and Validation sets
trainingSet = processedData(training(cv,1),:);
validationSet = processedData(test(cv,1),:);

%% Define Build and test model settings
modelTech = 'Constant';
useDemoData = true;
usedContexts = {'hau', 'listening', 'userinitiated','ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present
useNaNVals = false;

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts,useDemoData,useNaNVals);
dummyValidationTable = dummyFunc(validationSet,usedContexts,useDemoData,useNaNVals);

dummyTrainingArray = table2array(dummyTrainingTable);

%% Build Model
mdl = stepwiseglm(dummyTrainingArray(:,1:size(dummyTrainingArray,2) - 1), dummyTrainingArray(:,size(dummyTrainingArray,2)),modelTech,'VarNames', ...
    dummyTrainingTable.Properties.VariableNames);
        

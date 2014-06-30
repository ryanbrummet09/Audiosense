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
attributes = {'sp', 'le', 'ld2', 'lcl','ap','im', 'st'}; %'sp', 'le', 'ld', 'ld2', 'lcl', 'ap','qol','im', 'st'}
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

%% Produce Combined Score
score = zeros(size(processedData,1),1);
for k = 1 : size(attributes,2)
    score = nansum([score, processedData.(attributes{k})],2);
    processedData.(attributes{k}) = [];
end
processedData.score = score + 1;

%% Produce Training and Validation sets
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
trainingSet = processedData(training(cv,1),:);
validationSet = processedData(test(cv,1),:);

%% Define Build and test model settings
modelTech = 'Linear';
useDemoData = true;
usedContexts = {'hau', 'listening', 'userinitiated','ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present
useNaNVals = false;

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts,useDemoData,useNaNVals);
dummyValidationTable = dummyFunc(validationSet,usedContexts,useDemoData,useNaNVals);

dummyTrainingArray = table2array(dummyTrainingTable);

%% Build Model
%if you are using gamma distribution, you need to add one to each score so
%that all scores are positive (ie not negative OR zero).  If you are not
%using the gamma distribution, make sure that you are not adding one to the
%score.
mdl = stepwiseglm(dummyTrainingArray(:,1:size(dummyTrainingArray,2) - 1), dummyTrainingArray(:,size(dummyTrainingArray,2)),modelTech,'VarNames', ...
    dummyTrainingTable.Properties.VariableNames,'Distribution','gamma');


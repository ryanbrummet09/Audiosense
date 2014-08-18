%Ryan Brummet
%University of Iowa

%Builds a model using the repeated measures technique.

%We look here at only raw data, the data has not been adjusted in any way
%shape or form other than the standard preprocessing

%% initialize
close all;
clear;
clc;

dataFileName = 'DataTable.mat';  %must be .mat file, variable must be 'unProcessedData'
contextSubset = {'patient','listening','ac','lc','tf','vc','tl','nl','rs','cp','nz','condition'};
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;   %a user not having this # of samples has all samples removed
minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]

outerCrossValFolds = 5;
innerCrossValFolds = 5;
groupVars = {'ac','lc','nz','patient','condition'};  %used to build a composite variable that is used to statify in cross validation
randomizeDataSampleOrder = true;

%% global variables
%we remove ld, im, and qol becuase scores from these attr do not reflect HA
%performance
attributes = {'sp', 'le', 'ld2', 'lcl', 'ap', 'st'}; %{'sp', 'le', 'ld', 'ld2', 'lcl', 'ap', 'qol', 'im', 'st'}
contexts = {'hau', 'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
miscDataInfo = {'patient', 'listening', 'userinitiated', 'hau',};
combineScoreInfo = {'AVG', 'SUM', 'MEDIAN', 'STD', 'MAX', 'MIN'};
extractedColNames = [miscDataInfo contexts attributes];

%% preprocess data
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
         unProcessedData((unProcessedData.(attributes{k}) == 50) ...
             & (unProcessedData.timestamp < fiftyCorrectionDate),:) = [];
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

%reasign attr values so that large values are 'good' and small values are
%'bad'.
unProcessedData.le = 100 - unProcessedData.le;
unProcessedData.ap = 100 - unProcessedData.ap;

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

%convert listening to numeric
processedData.listening(strcmp(processedData.listening,''),1) = {'NaN'};
processedData.listening = str2num(char(processedData.listening)) + 1;

%clear variables that are no longer needed
clearvars fiftyCorrectionDate unProcessedData 

cvVar = zeros(size(processedData,1),1);
for cs = 0 : size(groupVars,2) - 1
    if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
        if strcmp(char(groupVars{cs + 1}),'patient')
            cvVar = cvVar + processedData.patient;
        else
            cvVar = cvVar + processedData.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
        end
        
    else
        cvVar = cvVar + processedData.(groupVars{cs + 1}) * 10 ^ (-cs);
    end
end
processedData.cvVar = cvVar;

outerCV = cvpartition(processedData.cvVar,'kfold',outerCrossValFolds);
validationSet = processedData(test(outerCV,1),:);
trainingSet = processedData(training(outerCV,1),:);

%% remove non-features and replace NaN values with zero
trainingSet.userinitiated =[];
validationSet.userinitiated = [];

trainingSet.hau = [];
validationSet.hau = [];

trainingSet.hau_1 = [];
validationset.hau_1 = [];

trainingSet.cvVar = [];
validationSet.cvVar = [];

for k = 1 : size(contextSubset,2)
   temp = trainingSet.(contextSubset{k});
   temp(isnan(temp)) = 0;
   trainingSet.(contextSubset{k}) = temp;
   
   temp = validationSet.(contextSubset{k});
   temp(isnan(temp)) = 0;
   validationSet.(contextSubset{k}) = temp;
end

%% build starting model
model = 'sp,le,ld2,lcl,ap,st ~ 1';

depVars = {'listening','ac','lc','tf','tl','nl','nz','vc','cp','rs'};
for k = 1 : size(depVars,2)
     model = strcat(strcat(model,{' + '}),strcat(strcat('patient',':'),depVars{k})); 
     model = strcat(strcat(model,{' + '}),strcat(strcat('condition',':'),depVars{k}));
end
model = strcat(strcat(model,{' + '}),'patient * condition');
model = char(model);

%% average the responses of duplicate contexts and convert context subsets into nominal variables
%first we build a unique Identifier for eacht context
cvVar = zeros(size(trainingSet,1),1);
for cs = 0 : size(contextSubset,2) - 1
    if strcmp(char(contextSubset{cs + 1}),'patient') || strcmp(char(contextSubset{cs + 1}),'condition')
        if strcmp(char(contextSubset{cs + 1}),'patient')
            cvVar = cvVar + trainingSet.patient;
        else
            cvVar = cvVar + trainingSet.(contextSubset{cs + 1}) * 10 ^ (-cs - 1);
        end
        
    else
        cvVar = cvVar + trainingSet.(contextSubset{cs + 1}) * 10 ^ (-cs);
    end
end
trainingSet.cvVar = cvVar;

cvVarUnique = unique(trainingSet.cvVar);
for k = 1 : size(cvVarUnique,1)
    x = find(trainingSet.cvVar == cvVarUnique(k));
    if size(x,1) > 1
        y = table2array(trainingSet(x,:));
        y = array2table(mean(y));
        y.Properties.VariableNames = trainingSet.Properties.VariableNames;
        trainingSet(x(1),:) = y;
        trainingSet(x(2:size(x,1)),:) = [];
    end
end

trainingSet2 = table;
validationSet2 = table;
letters = {'A','B','C','D','E','F','G'};
for k = 1 : size(contextSubset,2)
    temp = nominal(trainingSet.(contextSubset{k}));
    myUnique = unique(temp);
    if ~strcmp(contextSubset{k},'patient') && ~strcmp(contextSubset{k},'condition')
        for j = 1 : size(myUnique,1)
            temp(ismember(temp,myUnique(j))) = letters{j}; 
        end
    end
    trainingSet2.(contextSubset{k}) = nominal(temp);
end
for k = 1 : size(attributes,2)
    trainingSet2.(attributes{k}) = trainingSet.(attributes{k});
    validationSet2.(attributes{k}) = validationSet.(attributes{k});
end

trainingSet2.Properties.VariableNames = {'Var1','Var2','Var3','Var4','Var5','Var6','Var7','Var8','Var9','Var10','Var11','Var12','Var13','Var14','Var15','Var16','Var17','Var18'};

%% build model
mdl = fitrm(trainingSet2,model);
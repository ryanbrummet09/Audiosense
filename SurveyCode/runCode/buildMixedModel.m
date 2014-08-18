%Ryan Brummet
%University of Iowa

%Builds a model using the mixed model technique.

%We look here at only raw data, the data has not been adjusted in any way
%shape or form other than the standard preprocessing.  We use the same
%model to predict each response value, finding different coefficients for
%each

%% initialize
close all;
clear;
clc;

%must be .mat file, variable must be 'unProcessedData'
dataFileName = 'DataTable.mat';  

%predictor values to use
%possible values are:    %{'patient','listening','ac','lc','tf','vc','tl','nl','rs','cp','nz','condition'}
predictors = {'patient','ac','lc','tf','vc','tl','nl','rs','cp','nz','condition'};

%the response variables that we will created individual models for (the
%models are the same but the coefficients will differ)
%possible values are:   {'sp', 'le', 'ld', 'ld2', 'lcl', 'ap', 'qol', 'im', 'st'}
responses = {'sp', 'le', 'ld2', 'lcl', 'ap', 'st'}; 

%gives the base model that will be used to predict the response variables
baseModel = 'ac + lc + tl + tf + nl + nz + vc + rs + cp + condition + (1 | patient)';

%If the linear dependence is detected between predictor categories we 
%remove predictor categories until there is no longer linear dependence 
%(ie there is no longer rank deficiency).  Categories of predictors listed
%in this variable will not be removed.
necessaryPredictors = {'patient'};

%values to be removed from data table before creating training and
%validation sets
removeFeatures = {'cvVar'};

%pre-processing options
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;   %a user not having this # of samples has all samples removed

%this value is still included so that a function runs correctly, but is not
%longer used or needed.  I decided to stop putting limitations on how long
%a user could spend taking a survey
minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]

%defines how how big our training and validation sets will be (5 means 80%
%in training, 20% in validation)
outerCrossValFolds = 5;

%defines how data should be grouped, if at all, before splitting into
%training and validation sets
%IF CONDITION IS PRESENT IT MUST BE PLACED LAST IN THE VECTOR
groupVars = {'ac','lc','nz','patient','condition'};

%if true, the data set is randomized by row before the training and
%validation sets are created
randomizeDataSampleOrder = true;

%% Preprocess Data
extractedColNames = [predictors responses];

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
    for k = 1 : size(responses,2)
         unProcessedData((unProcessedData.(responses{k}) == 50) ...
             & (unProcessedData.timestamp < fiftyCorrectionDate),:) = [];
    end
end


%remove samples where all attributes are NaN
toBeRemoved = zeros(size(unProcessedData,1),1);
for k = 1 : size(responses,2)
    toBeRemoved = isnan(unProcessedData.(responses{k})) + toBeRemoved;
end
unProcessedData = unProcessedData(toBeRemoved < size(responses,2),:);

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
        
    %we recode condition99 as condition0 so that it will be treated as the
    %reference variable after dummy encoding by the built in matlab code
    elseif conditionVals(k,1) == 99
        conditionVals(k,1) = 0; 
    end
end
processedData.condition = conditionVals;

%convert listening to numeric
if sum(ismember(extractedColNames,'listening')) > 1
    processedData.listening(strcmp(processedData.listening,''),1) = {'NaN'};
    processedData.listening = str2num(char(processedData.listening)) + 1;
end

%convert predictor NaN values to 0
for k = 1 : size(predictors,2)
    temp = processedData.(predictors{k});
    temp(isnan(temp)) = 0;
    processedData.(predictors{k}) = temp;
end

%clear variables that are no longer needed
clearvars fiftyCorrectionDate unProcessedData 

%build grouping feature
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

%build partition for training and validation sets
outerCV = cvpartition(processedData.cvVar,'kfold',outerCrossValFolds);
processedData.cvVar = [];

%conver all predictor NaN values to zero
for k = 1 : size(predictors,2)
    temp = processedData.(predictors{k});
    temp(isnan(temp)) = 0;
    processedData.(predictors{k}) = temp;
end

%% Dummy encode to remove linearly dependent dummy variables
%DUMMY ENCODE, first we need to find how many possibilities there are for
%each predictor variable
for k = 1 : size(predictors,2)
    temp = unique(processedData.(predictors{k}));
    temp(temp == 0) = [];
    amount(k) = size(temp(~isnan(temp)),1);
end

%next we create the dummy variables
dummyVars = zeros(size(processedData,1),sum(amount));
for k = 1 : size(processedData,1)
    for j = 1 : size(predictors,2)
        temp = unique(processedData.(predictors{j}));
        temp(temp == 0) = [];
        if j == 1
            dummyVars(k,find(temp == processedData.(predictors{j})(k))) = 1;
        else
            dummyVars(k,sum(amount(1:j - 1)) + find(temp == processedData.(predictors{j})(k))) = 1;
        end
    end
end

%here we name the dummy variables (we also turn dummyVars into a table
dummyVars = array2table(dummyVars);
index = 1;
for k = 1 : size(predictors,2)
    temp = unique(processedData.(predictors{k}));
    temp(temp == 0) = [];
    for j = 1 : amount(k)
        dummyVars.Properties.VariableNames{strcat('dummyVars',num2str(index))} = strcat(predictors{k},num2str(temp(j)));
        index = index + 1;
    end
end

%here we find and remove linearly dependent dummy variables
%if the number of dummy features is equal to the rank of the dummy matrix
%we do not need to remove dummy features.  However if they are not equal
%one or more dummy features is linearly dependent on the other other
%features.  We must find and remove each linearly dependent feature.
linDepDummyVars = NaN;
dummyMatrix = table2array(dummyVars);
if rank(dummyMatrix) < size(dummyMatrix,2)
    linDepIndexes = [1:size(dummyMatrix,2)];
    indDepIndexes = [];
    while size(linDepIndexes,2) > size(dummyMatrix,2) - rank(dummyMatrix)
        if ceil(size(linDepIndexes,2)/2) == size(dummyMatrix,2) - rank(dummyMatrix)
            break;
        elseif ceil(size(linDepIndexes,2)/2) < size(dummyMatrix,2) - rank(dummyMatrix)
            checkIndexes = randi(size(linDepIndexes,2));
        else
            checkIndexes = randperm(size(linDepIndexes,2),ceil(size(linDepIndexes,2)/2));
        end
        while rank(dummyMatrix(:,[indDepIndexes linDepIndexes(checkIndexes)])) < size(dummyMatrix(:,[indDepIndexes linDepIndexes(checkIndexes)]),2)
            if ceil(size(linDepIndexes,2)/2) < size(dummyMatrix,2) - rank(dummyMatrix)
                checkIndexes = randi(size(linDepIndexes,2));
            else
                checkIndexes = randperm(size(linDepIndexes,2),ceil(size(linDepIndexes,2)/2));
            end
        end
        indDepIndexes = [indDepIndexes linDepIndexes(checkIndexes)];
        linDepIndexes(checkIndexes) = [];
    end
    
    temp = dummyVars.Properties.VariableNames;
    linDepDummyVars = temp(linDepIndexes);
    for k = 1 : size(linDepDummyVars,2)
        dummyVars.(linDepDummyVars{k}) = []; 
    end
end


%% Build model OR remove lin dep categories from processedData
%we treat patient as a grouping variable with random effects while all
%other predictors are fixed.  All models derive from this
% baseModel = '';
% dummyGroupVars = '';
% dummyFixedVars = '';
% groupIndex = 1;
% fixedIndex = 1;
% for k = 1 : size(dummyVars,2)
%     if size(dummyVars.Properties.VariableNames{k},2) > 7 && ~strcmp(dummyVars.Properties.VariableNames{k}(1),'c')
%        if  strcmp(dummyVars.Properties.VariableNames{k}(1:7),'patient')
%            dummyGroupVars{groupIndex} = dummyVars.Properties.VariableNames{k};
%            groupIndex = groupIndex + 1;
%        end
%     else
%         dummyFixedVars{fixedIndex} = dummyVars.Properties.VariableNames{k};
%         baseModel = strcat(baseModel,{' + '},dummyFixedVars{fixedIndex});
%         fixedIndex = fixedIndex + 1;
%     end
% end
% 
% for k = 1 : size(dummyGroupVars,2)
%     baseModel = strcat(baseModel,{' + (1 | '},dummyGroupVars{k},')');
%     for j = 1 : size(dummyFixedVars,2)
%         baseModel = strcat(baseModel,{' + ('},dummyFixedVars{j},{' | '},dummyGroupVars{k},')');
%     end
% end

%Here we remove variable categories that are linearly dependent
for k = 1 : size(linDepDummyVars,2)
    if size(linDepDummyVars{k},2) == 3
        value = str2num(linDepDummyVars{k}(3:size(linDepDummyVars{k},2)));
        temp = processedData.(linDepDummyVars{k}(1:2));
        temp(temp == value) = 0;
        processedData.(linDepDummyVars{k}(1:2)) = temp;
    else
        if strcmp(linDepDummyVars{k}(1),'p')
            value = str2num(linDepDummyVars{k}(8:size(linDepDummyVars{k},2)));
            temp = processedData.patient;
            temp(temp == value) = 0;
            processedData.patient = temp;
        else
            value = str2num(linDepDummyVars{k}(10:size(linDepDummyVars{k},2)));
            temp = processedData.condition;
            temp(temp == value) = 0;
            processedData.condition = temp;
        end
    end
end

%% Convert predictors to nominal and create training and validation sets 
for k = 1 : size(predictors,2)
    processedData.(predictors{k}) = nominal(processedData.(predictors{k}));
end

%maybe removed start
load('scoreTemp.mat');
dummyVars = [dummyVars combinedScoreData(:,'score')];
%maybe removed end

processedData = [processedData(:,predictors),combinedScoreData(:,'score')];

trainingSet = table2dataset(processedData(training(outerCV,1),:));
validationSet = table2dataset(processedData(test(outerCV,1),:));

%dummyVars = [dummyVars processedData(:,responses)];
% trainingSet = table2dataset(dummyVars(training(outerCV,1),:));
% validationSet = table2dataset(dummyVars(test(outerCV,1),:));

%% Create mixed model for each response variable based on baseModel
disp('Started');
model = '';
model = char(strcat({'sp ~ 1'},baseModel));
mixedModelSP = fitlme(trainingSet,model);
disp(1);

model = '';
model = char(strcat({'le ~ 1'},baseModel));
mixedModelLE = fitlme(trainingSet,model);
disp(2);

model = '';
model = char(strcat({'ld2 ~ 1'},baseModel));
mixedModelLD2 = fitlme(trainingSet,model);
disp(3);

model = '';
model = char(strcat({'lcl ~ 1'},baseModel));
mixedModelLCL = fitlme(trainingSet,model);
disp(4);

model = '';
model = char(strcat({'ap ~ 1'},baseModel));
mixedModelAP = fitlme(trainingSet,model);
disp(5);

model = '';
model = char(strcat({'st ~ 1'},baseModel));
mixedModelST = fitlme(trainingSet,model);
disp(6);

%Ryan Brummet
%University of Iowa

%This script builds a mixed model that predicts scores from our audiology
%surveys

%% Initialize
close all;
clear;
clc;

dataFileName = 'DataTable.mat';
demo1FileName = 'demographics.mat';
demo2FileName = 'ptaInfo.mat';

predictors = {'patient','condition','tf','tl','nl','lc','ac','nz','cp','rs','vc'};

%a predictor cannot be in both numericPredictors and necessaryPredictors.
%If a predictor is numeric, it is automatically considered necessary.
numericPredictors = '';
necessaryPredictors = {'patient','condition'};

%can be {'sp','le','ld2','lcl','ap','st'}
responses = {'sp','le','ld2','lcl','ap','st'};

%the input used here is dependent on the model type that is used
% 'score ~ 1 + ac*lc + tl + tf + nl*nz + cp*rs + vc + condition*patient + ac*condition + ac*patient + lc*condition + lc*patient + nz*condition + nz*patient + vc*condition*patient'
baseModel = 'score ~ 1 + ac*condition*patient + lc*condition*patient + tl*condition*patient + tf*condition*patient + nl*condition*patient + nz*condition*patient + cp*condition*patient + rs*condition*patient + vc*condition*patient';

%can be mixed, stepwise, glm, or repeatMeas
modelType = 'stepwise';  

%if true, average left and right ear demo hearing values
avgDemo = false;

%if true dummy variables are found and input into model function by hand
keepDummyVars = false;

%if true, convert dB to magnitude (logrithmic to linear scale)
convertdB = false;

%if true, find the total average of score, the average score for each user
%and find the differences.  Correct each user sample by it's corresponding
%difference.  Differences are found using only the training set to maintain
%seperation between training and validaiton sets
scaleScoreByAvg = false;

%options are sp, le, ld2, lcl, ap, st and combined.  If the option is not
%combined, we map onto the given target
target = 'st'; 
predRawScore = false;
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;

%% Preprocess Data
[ processedData, outerCV ] = preProcessesData4Model( dataFileName, demo1FileName, demo2FileName,  ...
    predictors, numericPredictors, responses, removeFifties, omitListening, omitNotListening, omitUserInit, ...
    omitNotUserInit, omitWearingHearingAid, omitNotWearingHearingAid, minNumSamplesPerUser, ...
    necessaryPredictors, keepDummyVars,convertdB,modelType);

%% Misc
%we average SNL and pta features here
if avgDemo
    temp = table;
    temp.SNRLoss = mean([processedData.SNRLossLeft processedData.SNRLossRight],2);
    temp.pta124 = mean([processedData.pta124Left processedData.pta124Right],2);
    temp.pta512 = mean([processedData.pta512Left processedData.pta512Right],2);

    processedData.SNRLossLeft = [];
    processedData.SNRLossRight = [];
    processedData.pta124Left = [];
    processedData.pta124Right = [];
    processedData.pta512Left = [];
    processedData.pta512Right = [];
    
    processedData = [temp processedData];
    
    predictors(strcmp(predictors,'SNRLossLeft')) = [];
    predictors(strcmp(predictors,'SNRLossRight')) = [];
    predictors(strcmp(predictors,'pta124Left')) = [];
    predictors(strcmp(predictors,'pta124Right')) = [];
    predictors(strcmp(predictors,'pta512Left')) = [];
    predictors(strcmp(predictors,'pta512Right')) = [];
    predictors(size(predictors,2) + 1) = {'SNRLoss'};
    predictors(size(predictors,2) + 1) = {'pta124'};
    predictors(size(predictors,2) + 1) = {'pta512'};
end

%% Produce training and validation sets
trainingSet = processedData(training(outerCV,1),:);
validationSet = processedData(test(outerCV,1),:);

%% Create response score
if predRawScore
    for k = 1 : size(responses,2)
        if strcmp(responses{k},target)
            trainingSet.score = trainingSet.(responses{k});
            validationSet.score = validationSet.(responses{k});
            trainingSet.(responses{k}) = [];
            validationSet.(responses{k}) = [];
        else
            trainingSet.(responses{k}) = []; 
            validationSet.(responses{k}) = [];
        end
    end
else
    index = 1;
    if size(target,2) > 3
        trainingSet.score = nanmean(table2array(trainingSet(:,responses)),2);
        validationSet.score = nanmean(table2array(validationSet(:,responses)),2);
        trainingSet(:,responses) = [];
        validationSet(:,responses) = [];
    else
        for k = 1 : size(responses,2)
            if ~strcmp(responses{k},target)
                targetSamples = ~isnan(trainingSet.(target)) & ~isnan(trainingSet.(responses{k}));
                mapCoef = fliplr(robustfit(trainingSet.(responses{k})(targetSamples),trainingSet.(target)(targetSamples))');
                trainingScore(:,index) = evaluatePolynomial(mapCoef,trainingSet.(responses{k}));
                validationScore(:,index) = evaluatePolynomial(mapCoef,validationSet.(responses{k}));
                index = index + 1;
            else
                trainingScore(:,index) = trainingSet.(responses{k});
                validationScore(:,index) = validationSet.(responses{k});
                index = index + 1;
            end
        end
        trainingSet.score = nanmean(trainingScore,2);
        validationSet.score = nanmean(validationScore,2);
        trainingSet(:,responses) = [];
        validationSet(:,responses) = [];
    end
end

if scaleScoreByAvg
    trainingAvg = mean(trainingSet.score);
    patientIDs = unique(processedData.patient);
    for k = 1 : size(patientIDs,1)
        patientCorrection(k) = trainingAvg - mean(trainingSet.score(patientIDs(k) == trainingSet.patient));
        trainingSet.score(patientIDs(k) == trainingSet.patient) = trainingSet.score(patientIDs(k) == trainingSet.patient) + patientCorrection(k);
        validationSet.score(patientIDs(k) == validationSet.patient) = validationSet.score(patientIDs(k) == validationSet.patient) + patientCorrection(k);
    end
end


%% Produce model
disp('Started');
if keepDummyVars || sum(ismember(predictors,'patient')) == 0
    trainingSet.patient = [];
    validationSet.patient = [];
end
trainingSet = table2dataset(trainingSet);
validationSet = table2dataset(validationSet);

if strcmp(modelType,'glm')
    mdl = fitglm(trainingSet,baseModel,'DummyVarCoding','full');
elseif strcmp(modelType,'stepwise')
    mdl = stepwiseglm(trainingSet,baseModel,'Criterion','bic','Distribution','gamma');
elseif strcmp(modelType,'mixed')
    mdl = fitlme(trainingSet,baseModel,'DummyVarCoding','full');
else
    
end

%% Evaluate model against validation set
temp = predict(mdl,trainingSet(:,predictors));
temp(temp < 0) = 0;
temp(temp > 100) = 100;
modelScoresTraining = temp;
temp = predict(mdl,validationSet(:,predictors));
temp(temp < 0) = 0;
temp(temp > 100) = 100;
modelScoresValidation = temp;

absErrorTraining = abs(trainingSet.score - modelScoresTraining);
absErrorValidation = abs(validationSet.score - modelScoresValidation);

trainingSet.Predicted = modelScoresTraining;
trainingSet.Error = absErrorTraining;
validationSet.Predicted = modelScoresValidation;
validationSet.Error = absErrorValidation;

[temp, index] = sort(trainingSet.Error);
trainingSet = flipud(trainingSet(index,:));
[temp, index] = sort(validationSet.Error);
validationSet = flipud(validationSet(index,:));


%score ~ vc2 + vc1 + rs2 + rs1 + cp1 + nz3 + nz2 + ac6 + ac3 + ac2 + ac1 + lc5 + lc4 + lc3 + lc2 + lc1 + nl4 + nl3 + nl2 + nl1 + tl3 + tl2 + tl1 + tf4 + tf3 + tf2 + tf1 + condition5 + condition4 + condition3 + condition2 + condition1 + (1 | SNRLossLeft) + (1 | SNRLossRight) + (1 | pta124Left) + (1 | pta124Right) + (1 | pta512Left) + (1 | pta512Right)
disp(mdl.Rsquared);
cdfplot(absErrorTraining);
hold on;
cdfplot(absErrorValidation);
figure;
hist(trainingSet.score,100);


%Ryan Brummet
%University of Iowa

%Builds and tests a model against composite scores

%% initialize
clear;
close all;
clc;

dataFileName = '/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_ap_UsingAVG.mat';
usedContexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};

%% load data
load(dataFileName);

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts);
dummyValidationTable = dummyFunc(validationSet,usedContexts);

dummyTrainingArray = table2array(dummyTrainingTable);

%% Build Model
mdl = stepwiseglm(dummyTrainingArray(:,1:size(dummyTrainingArray,2) - 1), dummyTrainingArray(:,size(dummyTrainingArray,2)),'constant','VarNames', ...
    dummyTrainingTable.Properties.VariableNames);

%% Evaluate Model against validation set (find coefficient of determination)
%remove dummy variables that are not part of the created model
predictiveNames = mdl.PredictorNames;
for k = 1 : size(predictiveNames,1)
    dummyValidationArray(:,k) = dummyValidationTable.(char(predictiveNames(k,1))); 
end
dummyValidationArray(:,size(dummyValidationArray,2) + 1) = dummyValidationTable.score;
modelScores = mdl.feval(dummyValidationArray(:,1:size(predictiveNames)));

SSres = sum((dummyValidationArray(:,size(dummyValidationArray,2)) - modelScores).^2);
SStot = sum((dummyValidationArray(:,size(dummyValidationArray,2)) - mean(dummyValidationArray(:,size(dummyValidationArray,2)))).^2);

coefOfDet = 1 - SSres/SStot;
%Ryan Brummet
%University of Iowa

%Builds and tests a model against composite scores

%% initialize
clear;
close all;
clc;

modelTech = 'Constant';
combineTech = 'SUM';
target = 'ap';
norm = 'UserNorm';  %can be NoNorm, GlobalNorm, or UserNorm
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',target,'_Using',combineTech,norm,'.mat'));
usedContexts = {'hau', 'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present


%% load data
load(dataFileName);

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts);
dummyValidationTable = dummyFunc(validationSet,usedContexts);

dummyTrainingArray = table2array(dummyTrainingTable);

%% Build Model
mdl = stepwiseglm(dummyTrainingArray(:,1:size(dummyTrainingArray,2) - 1), dummyTrainingArray(:,size(dummyTrainingArray,2)),modelTech,'VarNames', ...
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

clearvars k;

save(char(strcat('compositeScoreResults_',target,modelTech)));


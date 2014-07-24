%Ryan Brummet
%University of Iowa

%Builds and tests a model against composite scores

%% initialize
clear;
close all;
clc;

modelTech = 'userBuilt';  %options are constant, linear, interactions, purequadratic, quadratic, polyijk, or userBuilt
criterion = 'Deviance';  %options are Deviance (default), sse, aic (akaike information criterion),
                    %bic (bayesian information criterion), rsquared, adjrsquared
combineTech = 'SUMADJR'; %can be AVG, SUM, MEDIAN, STD
target = 'NoMap';
useDemoData = false;
norm = 'NoNorm';  %can be NoNorm, GlobalNorm, or UserNorm
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',target,'_Using',combineTech,norm,'.mat'));
usedContexts = {'listening', 'userinitiated','ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present
useNaNVals = false;
plotError = false;
sendEmail = false;

%% load data
load(dataFileName);

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts,useDemoData,useNaNVals);
dummyValidationTable = dummyFunc(validationSet,usedContexts,useDemoData,useNaNVals);

%% Change variables to categorical variables
varNames = dummyTrainingTable.Properties.VariableNames;
for k = 1 : size(varNames,2) - 1
    dummyTrainingTable.(varNames{k}) = categorical(dummyTrainingTable.(varNames{k}));
    dummyValidationTable.(varNames{k}) = categorical(dummyValidationTable.(varNames{k}));
end

dummyTrainingTable = table2dataset(dummyTrainingTable);
dummyValidationTable = table2dataset(dummyValidationTable);

%% Here we build the model by hand if modelTech == 'userBuilt'
%each model is built by hand so this section must be rebuilt each time a
%different user model is built (if the model is different that is)
if strcmp(modelTech,'userBuilt')
    patientIDs = unique(trainingSet.patient);
    conditionIDs = unique(trainingSet.condition);
    depVars = {'ac1','ac2','ac3','ac4','ac5','ac6','ac7','lc1','lc2','lc3','lc4','lc5', ...
        'tf1','tf2','tf3','tf4','vc1','vc2','vc3','tl1','tl2','tl3','nl1','nl2','nl3', ...
        'nl4','rs1','rs2','rs3','cp1','cp2','nz1','nz2','nz3','nz4'};
    modelTech = '';
    for k = 1 : size(patientIDs,1)
        for j = 1 : size(depVars,2)
            if strcmp(modelTech,'')
                modelTech = strcat(strcat(strcat('Patient',num2str(patientIDs(k))),':'),depVars{j});
            else
                modelTech = strcat(strcat(modelTech,{' + '}),strcat(strcat(strcat('Patient',num2str(patientIDs(k))),':'),depVars{j}));
            end
        end
    end
    modelTech = char(modelTech);
    
    for k = 1 : size(conditionIDs,1)
        for j = 1 : size(depVars,2)
            modelTech = strcat(strcat(modelTech,{' + '}),strcat(strcat(strcat('condition',num2str(conditionIDs(k))),':'),depVars{j}));
        end
    end
    modelTech = char(modelTech);
    modelTech = strcat({'score ~ 1 + '},modelTech);
    modelTech = char(modelTech);
end
%% Build Model
mdl = stepwiseglm(dummyTrainingTable,modelTech,'Criterion',criterion);

%% Evaluate Model against validation set (find coefficient of determination)
%remove dummy variables that are not part of the created model
predictiveNames = mdl.PredictorNames;
for k = 1 : size(predictiveNames,1)
    pickedCoefValidationArray(:,k) = dummyValidationTable.(char(predictiveNames(k,1))); 
    pickedCoefTrainingArray(:,k) = dummyTrainingTable.(char(predictiveNames(k,1)));
end
pickedCoefValidationArray(:,size(pickedCoefValidationArray,2) + 1) = dummyValidationTable.score;
pickedCeofTrainingArray(:,size(pickedCoefTrainingArray,2) + 1) = dummyTrainingTable.score;

modelScoresValidation = mdl.feval(pickedCoefValidationArray(:,1:size(predictiveNames)));
modelScoresTraining = mdl.feval(pickedCoefTrainingArray(:,1:size(predictiveNames)));

absErrorTraining = abs(dummyTrainingTable.score - modelScoresTraining);
absErrorValidation = abs(dummyValidationTable.score - modelScoresValidation);

if plotError
    a = cdfplot(absErrorTraining);
    set(a,'color','b');
    hold on;
    b = cdfplot(absErrorValidation);
    set(b,'color','r');
    hold off;
    legend('Training','Validation');
    if useDemoData
        title(char(strcat('Map onto',{' '},target,{' '},'Using',{' '},norm,',',{' '},combineTech,{', and demoData with'},{' '},modelTech,{' '},'model')));
    else
        title(char(strcat('Map onto',{' '},target,{' '},'Using',{' '},norm,',',{' '},combineTech,{', and NO demoData with'},{' '},modelTech,{' '},'model')));
    end
    xlabel('Absoluate Error');
    ylabel('Cumulative Probability');
end

if useDemoData
    save(char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoTRUE')));
    if sendEmail
        sendGmail('ryanbrummet09@augustana.edu',char(strcat(modelTech,'_',combineTech,'_',norm,'_',num2str(useDemoData),'_',target)),'',char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoTRUE.mat')));
    end
else
    save(char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoFALSE')));
    if sendEmail
        sendGmail('ryanbrummet09@augustana.edu',char(strcat(modelTech,'_',combineTech,'_',norm,'_',num2str(useDemoData),'_',target)),'',char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoFALSE.mat')));
    end
end

if sendEmail
    quit;
else
    disp(modelTech);
    disp(target);
    disp(norm);
    disp(combineTech);
    disp(coefOfDet);
end
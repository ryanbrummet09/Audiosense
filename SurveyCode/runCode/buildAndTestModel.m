%Ryan Brummet
%University of Iowa

%Builds and tests a model against composite scores

%% initialize
clear;
close all;
clc;

modelTech = 'linear';  %options are constant, linear, interactions, purequadratic, quadratic, polyijk, or userBuilt
criterion = 'Deviance';  %options are Deviance (default), sse, aic (akaike information criterion),
                    %bic (bayesian information criterion), rsquared, adjrsquared
combineTech = 'AVG'; %can be AVG, SUM, MEDIAN, STD
target = 'le';
useDemoData = false;
norm = 'NoNorm';  %can be NoNorm, GlobalNorm, or UserNorm
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',target,'_Using',combineTech,norm,'.mat'));
usedContexts = {'listening','ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present
plotError = false;
sendEmail = false;

%% load data
load(dataFileName);
trainingTable = trainingSet;
validationTable = validationSet;

trainingTable.hau = [];
validationTable.hau = [];
trainingTable.cvVar = [];
validationTable.cvVar = [];
trainingTable.hau_1 = [];
validationTable.hau_1 = [];
trainingTable.userinitiated = [];
validationTable.userinitiated = [];

for k = 1 : size(usedContexts,2)
   temp = trainingTable.(usedContexts{k});
   temp(isnan(temp)) = 0;
   trainingTable.(usedContexts{k}) = temp;
   
   temp = validationTable.(usedContexts{k});
   temp(isnan(temp)) = 0;
   validationTable.(usedContexts{k}) = temp;
end
trainingTable = table2dataset(trainingTable);
validationTable = table2dataset(validationTable);
%% Here we build the model (by hand if modelTech == 'userBuilt')
%each model is built by hand so this section must be rebuilt each time a
%different user model is built (if the model is different that is)
if strcmp(modelTech,'userBuilt')
    depVars = {'listening','ac','lc','tf','tl','nl','nz','vc','cp','rs'};
    model = '';
    for k = 1 : size(depVars,2)
        if strcmp(model,'')
            model = strcat(strcat('patient','*'),depVars{k});
        else
            model = strcat(strcat(model,{' + '}),strcat(strcat('patient','*'),depVars{k}));
        end
    end
    model = char(model);
    for k = 1 : size(depVars,2)
        if strcmp(model,'')
            model = strcat(strcat('condition','*'),depVars{k});
        else
            model = strcat(strcat(model,{' + '}),strcat(strcat('condition','*'),depVars{k}));
        end
    end
    model = char(model);
    model = strcat({'score ~ 1 + patient*condition + '},model);
    model = char(model);
    
    mdl = stepwiseglm(trainingTable,model,'Criterion',criterion,'CategoricalVars',[1:size(trainingTable,2) - 1]);
    predictiveNames = mdl.PredictorNames;
    for k = 1 : size(predictiveNames,1)
        pickedCoefValidationArray(:,k) = validationTable.(char(predictiveNames(k,1))); 
        pickedCoefTrainingArray(:,k) = trainingTable.(char(predictiveNames(k,1)));
    end
    pickedCoefValidationArray(:,size(pickedCoefValidationArray,2) + 1) = validationTable.score;
    pickedCeofTrainingArray(:,size(pickedCoefTrainingArray,2) + 1) = trainingTable.score;

    temp = mdl.feval(pickedCoefValidationArray(:,1:size(predictiveNames)));
    temp(temp < 0) = 0;
    temp(temp > 100) = 100;
    modelScoresValidation = temp;
    temp = mdl.feval(pickedCoefTrainingArray(:,1:size(predictiveNames)));
    temp(temp < 0) = 0;
    temp(temp > 100) = 100;
    modelScoresTraining = temp;

    absErrorTraining = abs(trainingTable.score - modelScoresTraining);
    absErrorValidation = abs(validationTable.score - modelScoresValidation);
else
    mdl = stepwiseglm(trainingTable,modelTech,'Criterion',criterion,'CategoricalVars',[1:size(trainingTable,2) - 1]); 
    predictiveNames = mdl.PredictorNames;
    for k = 1 : size(predictiveNames,1)
        pickedCoefValidationArray(:,k) = validationTable.(char(predictiveNames(k,1))); 
        pickedCoefTrainingArray(:,k) = trainingTable.(char(predictiveNames(k,1)));
    end
    pickedCoefValidationArray(:,size(pickedCoefValidationArray,2) + 1) = validationTable.score;
    pickedCeofTrainingArray(:,size(pickedCoefTrainingArray,2) + 1) = trainingTable.score;

    temp = mdl.feval(pickedCoefValidationArray(:,1:size(predictiveNames)));
    temp(temp < 0) = 0;
    temp(temp > 100) = 100;
    modelScoresValidation = temp;
    temp = mdl.feval(pickedCoefTrainingArray(:,1:size(predictiveNames)));
    temp(temp < 0) = 0;
    temp(temp > 100) = 100;
    modelScoresTraining = temp;

    absErrorTraining = abs(trainingTable.score - modelScoresTraining);
    absErrorValidation = abs(validationTable.score - modelScoresValidation);
end


%% Evaluate Model against validation set (find coefficient of determination)
%remove dummy variables that are not part of the created model


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
    if sendEmail
        sendGmail('ryanbrummet09@augustana.edu',char(strcat(modelTech,'_',combineTech,'_',norm,'_',num2str(useDemoData),'_',target)),'',char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoFALSE.mat')));
    end
    save(char(strcat('Results/','CSR_',modelTech,'_',target,'_',norm,'_',combineTech,'_DemoFALSE')));
end

if sendEmail
    quit;
else
    disp(modelTech);
    disp(target);
    disp(norm);
    disp(combineTech);
    disp(mdl.Rsquared);
end
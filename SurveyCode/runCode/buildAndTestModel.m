%Ryan Brummet
%University of Iowa

%Builds and tests a model against composite scores

%% initialize
clear;
close all;
clc;

modelTech = 'Constant';
combineTech = 'SUM'; %can be AVG, SUM, MEDIAN, STD
target = 'le';
useDemoData = true;
norm = 'UserNorm';  %can be NoNorm, GlobalNorm, or UserNorm
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',target,'_Using',combineTech,norm,'.mat'));
usedContexts = {'hau', 'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};  %hau is very important to be present
plotError = false;
sendEmail = true;

%% load data
load(dataFileName);

%% make dummyScore set
dummyTrainingTable = dummyFunc(trainingSet,usedContexts,useDemoData);
dummyValidationTable = dummyFunc(validationSet,usedContexts,useDemoData);

dummyTrainingArray = table2array(dummyTrainingTable);

%% Build Model
mdl = stepwiseglm(dummyTrainingArray(:,1:size(dummyTrainingArray,2) - 1), dummyTrainingArray(:,size(dummyTrainingArray,2)),modelTech,'VarNames', ...
    dummyTrainingTable.Properties.VariableNames);

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
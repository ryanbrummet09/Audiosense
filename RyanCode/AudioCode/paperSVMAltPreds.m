% Ryan Brummet
% University of Iowa

close all;
clear;
clc;

%% Do not make modifications outside of this section
% IF YOU WANT TO CHANGE THE AUDIO FEATURES BEING EXTRACTED SEE LINE 60.
% THIS IS THE ONLY THING THAT MAY BE MODIFIED OUTSIDE THIS SECTION (LINE
% 60)

% give path to all files in AudioStuff directory.  This is needed only when
% ran on Ryan's mac
addpath(genpath('/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff'));
addpath(genpath('/Users/ryanbrummet/Documents/MATLAB/Extensions'));

% gives location to save results.  Make sure to include slash at end.
saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/Results/';

% Path to training and testing set .mat file.  Notice that you WILL STILL
% need to specify the correct response name below
processedDataLocation = 'Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/responseSets/sp.mat';

% Survey predictors to include
surveyPredictorNames = {'patient','condition'};

% Audio predictors to include. DO NOT CHANGE THIS unless we decide to
% change the audio features we are looking at
audioPredictorNames = {'ZeroCrossingRate','RMSV','Entropy', ...
    'SpectralRolloff','MFCC1','MFCC2','MFCC3','MFCC4','MFCC5','MFCC6', ...
    'MFCC7','MFCC8','MFCC9','MFCC10','MFCC11','MFCC12','MFCC13'};
audioFeatureIndexes = [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];

% SVM settings
degree = 1;
kernal = 2; %libsvm kernal setting
% Initial start values for grid search
startGammaValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000];
startCostValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000];

responseName = {'le'};

% features used for grouping when creating cross-validation folds
groupVars = {'patient','condition'};

outerCrossValFolds = 5;

seed = 100;

% if true combined cdfplot is created and saved at saveLocation
makePlot = true;

%% Preprocessing
disp('Preprocessing');

% extract audio features
load(processedDataLocation);
audioData = zeros(size(dataTable,1),size(audioPredictorNames,2));
for k = 1 : size(dataTable,1)
    load(dataTable.featureLocation{k});
    var(isinf(var)) = NaN;
    var = nanmean(var(:,audioFeatureIndexes));
    audioData(k,:) = var;
end

% build testing folds for outer cross validation
rng(seed);
cvVar = zeros(size(dataTable,1),1);
for cs = 0 : size(groupVars,2) - 1
    if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
        if strcmp(char(groupVars{cs + 1}),'patient')
            cvVar = cvVar + dataTable.patient;
        else
            cvVar = cvVar + dataTable.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
        end
    else
        cvVar = cvVar + dataTable.(groupVars{cs + 1}) * 10 ^ (-cs);
    end
end
dataTable.cvVar = cvVar;
outerCV = cvpartition(dataTable.cvVar,'kfold',outerCrossValFolds);
dataTable.cvVar = [];

% dummy encode patient and condition
zeroPreds = {'tf','tl','vc','cp','rs','nl','condition'};
for k = 1 : size(surveyPredictorNames,2)
    if k == 1 
        if ismember(surveyPredictorNames{k},zeroPreds)
            dummyVars = dummyvar(dataTable.condition + 1);
            dummyVars = dummyVars(:,2:end);
        else
            dummyVars = dummyvar(dataTable.(surveyPredictorNames{k}));
        end
    else
        if ismember(surveyPredictorNames{k},zeroPreds)
            temp = dummyvar(dataTable.condition + 1);
            dummyVars = [dummyVars,temp(:,2:end)];
        else
            dummyVars = [dummyVars,dummyvar(dataTable.(surveyPredictorNames{k}))];
        end
    end
end

targetData = [dummyVars,audioData,table2array(dataTable(:,responseName))];

%% Build SVM models for each outer fold
disp('Findingin Opt Params with radial basis function for outer folds');

cdfValues = struct;
for k = 1 : outerCrossValFolds
   folds{k} = strcat('fold',num2str(k)); 
end
for outerFolds = 1 : outerCrossValFolds
    disp(strcat('Outer Fold',{' '},num2str(outerFolds)));
    trainingSet = targetData(training(outerCV,outerFolds),:);
    testingSet = targetData(test(outerCV,outerFolds),:);
    
    gammaValues = startGammaValues;
    costValues = startCostValues;
    
    temp = dataTable(training(outerCV,outerFolds),:);
    rng(seed * 2);
    cvVar = zeros(size(temp,1),1);
    for cs = 0 : size(groupVars,2) - 1
        if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
            if strcmp(char(groupVars{cs + 1}),'patient')
                cvVar = cvVar + temp.patient;
            else
                cvVar = cvVar + temp.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
            end
        else
            cvVar = cvVar + temp.(groupVars{cs + 1}) * 10 ^ (-cs);
        end
    end
    temp.cvVar = cvVar;
    innerCV = cvpartition(temp.cvVar,'kfold',outerCrossValFolds);
    temp.cvVar = [];
    
    % find opt params for current outer fold using cross validation
    optParam = true;
    preOptC = NaN;
    preOptG = NaN;
    while optParam
        results = zeros(size(gammaValues,2),size(costValues,2),outerCrossValFolds);
        for innerFolds = 1 : outerCrossValFolds
            innerTraining = trainingSet(training(innerCV,innerFolds),:);
            innerTesting = trainingSet(test(innerCV,innerFolds),:);
            
            % scale inner training and testing sets using inner training
            % min and max
            for k = 1 : size(audioData,2)
                minimum = nanmin(innerTraining(:,size(dummyVars,2) + k));
                maximum = nanmax(innerTraining(:,size(dummyVars,2) + k));
                innerTraining(:,size(dummyVars,2) + k) = (innerTraining(:,size(dummyVars,2) + k) - minimum) / (maximum - minimum);
                innerTesting(:,size(dummyVars,2) + k) = (innerTesting(:,size(dummyVars,2) + k) - minimum) / (maximum - minimum);
            end
            
            % Grid Search
            for g = 1 : size(gammaValues,2)
                for c = 1 : size(costValues,2)
                    settings = strcat('-s 3 -t',{' '},num2str(kernal),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(gammaValues(g),'%f'),{' -c'},{' '},num2str(costValues(c),'%f')); 
                    mdl = svmtrain(innerTraining(:,end),innerTraining(:,1:end-1),settings{1});
                    preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
                    preds(preds < 0) = 0;
                    preds(preds > 100) = 100;
                    results(g,c,innerFolds) = sum(abs(preds - innerTesting(:,end)));
                end
            end
        end
        results = mean(results,3);
        [temp,index] = min(results(:));
        [optG,optC] = ind2sub(size(results),index);
        if optC == 1 || optG == 1 || optC == size(costValues,2) || optG == size(gammaValues,2)
            if isnan(preOptC) && isnan(preOptG)
                error('Initial range for startCost and startGammaValues is too small');
            elseif isnan(preOptC)
                error('Initial range for startCost is too small');
            elseif isnan(preOptG)
                error('Initial range for startGammaValues is too small');
            else
                optC = preOptC;
                optG = preOptG;
                optParam = false;
            end
        else
            preOptC = costValues(optC);
            preOptG = gammaValues(optG);
            costValues = [costValues(optC - 1), costValues(optC - 1) + ((costValues(optC) - costValues(optC - 1)) / 2), costValues(optC), costValues(optC) + ((costValues(optC + 1) - costValues(optC)) / 2), costValues(optC + 1)];
            gammaValues = [gammaValues(optG - 1), gammaValues(optG - 1) + ((gammaValues(optG) - gammaValues(optG - 1)) / 2), gammaValues(optG), gammaValues(optG) + ((gammaValues(optG + 1) - gammaValues(optG)) / 2), gammaValues(optG + 1)];
        end
    end
    
    % scale outer training and testing sets for current fold
    for k = 1 : size(audioData,2)
        minimum = nanmin(trainingSet(:,size(dummyVars,2) + k));
        maximum = nanmax(trainingSet(:,size(dummyVars,2) + k));
        trainingSet(:,size(dummyVars,2) + k) = (trainingSet(:,size(dummyVars,2) + k) - minimum) / (maximum - minimum);
        testingSet(:,size(dummyVars,2) + k) = (testingSet(:,size(dummyVars,2) + k) - minimum) / (maximum - minimum);
    end
    
    gamma(outerFolds) = optG;
    cost(outerFolds) = optC;
    settings = strcat('-s 3 -t',{' '},num2str(kernal),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(optG,'%f'),{' -c'},{' '},num2str(optC,'%f')); 
    mdl = svmtrain(trainingSet(:,end),trainingSet(:,1:end-1),settings{1}); 
    preds = svmpredict(testingSet(:,end),testingSet(:,1:end-1),mdl);
    preds(preds < 0) = 0;
    preds(preds > 100) = 100;
    cdfValues.(folds{outerFolds}) = abs(preds - testingSet(:,end));
end

save(strcat(saveLocation,responseName{1}),'cost','gamma','seed','cdfValues','targetData','degree','kernal','groupVars','startGammaValues','startCostValues');

if outerCrossValFolds == 5 && makePlot
    hold on;
    h = cdfplot(cdfValues.(folds{1}));
    set(h,'color','b');
    h = cdfplot(cdfValues.(folds{2}));
    set(h,'color','r');
    h = cdfplot(cdfValues.(folds{3}));
    set(h,'color','g');
    h = cdfplot(cdfValues.(folds{4}));
    set(h,'color','c');
    h = cdfplot(cdfValues.(folds{5}));
    set(h,'color','k');
    title(strcat('Cross Validation Results for',{' '},responseName{1}));
    xlabel('Abs Error');
    ylabel('Cumulative Percent');
    axis([0 100 0 1]);
    legend('Fold 1','Fold 2','Fold 3','Fold 4','Fold 5');
    hold off;
    savefig(strcat(saveLocation,responseName{1},'.fig'));
end


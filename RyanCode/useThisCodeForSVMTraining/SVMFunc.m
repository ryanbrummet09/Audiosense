% Ryan Brummet 
% University of Iowa
%
% Notice that this function creates a model for each specified fold
% with a grid search being conducte over only gamma and cost.  Every field
% for the inputStruct has a default value except for dataLocation, 
% response, and groupVars.  Change values as needed.  Field names given to 
% inputStruct must be exactly named as presented below.  For this script to
% run the catstruct library is needed.  You may find the library at
% http://www.mathworks.com/matlabcentral/fileexchange/7842-catstruct.  If
% using SVM libSVM is needed.  If creating a linear model use libLinear.
%
% NOTICE THAT THIS FUNCTION ASSUMES THAT THE ONLY CATEGORICAL VARIABLES
% THAT WILL EVER BE PASSED TO IT WILL BE MEMBERS OF THE SET [patient,
% condition, ac, lc, tf, tl, vc, cp, rs, nz, nl]
%
% Params: 
%    struct: inputStruct
%       fields: 
%           string: libLocation - location of libSVM library
%           int: libToUse - 1 to use libSVM library syntax. 2 to use
%                           liblLinear library syntax.  Default is libSVM.
%           cell array: dirsToPath - location of directories to add to
%                                    path.  Add by column NOT row.
%           string: saveLocation - location to save results; if not present
%                                  results are only returned, not saved.
%                                  Include the full name you wish to use.
%           string: dataLocation - location of dataset (must be table named
%                                  dataTable saved at this .mat location)
%           cell array: response - name of the response being predicted
%           int: numCores - gives the number of cores to use for parfor.
%                           Default is 1.
%           bool: makePlot - if true a graph is created. default is true.
%                            for this to run it must also be true that
%                            crossValFolds == 5
%           cell array: groupVars - gives predictors used to stratify folds
%           int: seed - gives the seed value for the RNG
%           int: maxIterCount - gives the max "zoom ins" for grid search.
%                               default is 10
%           int: crossValFolds - gives the number of inner/outer cross
%                                validation folds. default is 5
%           array: startGammaValues - gives initial grid search range for
%                                     gamma.  Must be column array not row
%           array: startCostValues - gives initial grid search range for
%                                    cost.  Must be column array not row
%           bool: allowGridSearchEdgeVals - if true values at the edge of
%                                           the grid search, search range
%                                           are allowed (no error thrown).
%                                           Default is false
%           int: degree - gives degree of SVM model. default is 1
%           int: kernel - gives kernal/solver using either libSVM or
%                         libLinear syntax.  Default is 2 (RBF) for libSVM
%                         and 11 (L2-regularized L2-loss support vector 
%                         regression, primal) for libLinear.
%           cellArray: toRemove - cell array of predictor names to remove.
% Return:
%   struct: SVMSettings
%       fields:
%           int: cost - optimal cost values for each fold
%           int: gamma - optimal gamma values for each fold
%           int: seed - seed value used
%           table: dataTable - table used to train and test model after bad
%                              predictors have been removed.
%           array: targetData - dummy encoded version of dataTable.  Each
%                               column corresponds to minimums and maximums
%                               fields of the mdlStruct struct returned
%           int: degree - degree used for SVM
%           int: kernal - SVM kernal using libSVM syntax
%           cell array: groupVars - gives predictors used to stratify folds
%           array: startGammaValues - gives initial grid search range for
%                                     gamma
%           array: startCostValues - gives initial grid search range for
%                                    cost
%           int: crossValFolds - gives the number of inner/outer cross
%                                validation folds
%           cell array: badPredNames - gives the names of predictors that
%                                      were removed from the table passed
%                                      to SVMFunc
%   struct: mdlStruct
%       fields:
%           libSVM model: mdl# - gives the model found for each outer fold 
%           array: minimums# - gives the minimum value of each numerical
%                              predictor that was used for scalings
%           array: maximums# - gives the maximum value of each numerical
%                              predictor that was used for scalings
%   struct: errorStruct
%       fields:
%           array: outerPred# - gives the prediction for each sample using mdl#
%                          on the testing fold
%           array: outerReal# - gives the real value for each sample of the
%                          testing fold. 
%           array: outer#Inner#Depth#Pred - gives the predicted values for
%                                           each sample of the inner fold
%                                           of the specified outer fold at
%                                           the given iteration depth
%                                           (maximum iteration depth is
%                                           given by the maxIterCount field
%                                           of inputStruct).
%           array: outer#Inner#Depth#Real - gives the real values for each
%                                           sample of the inner fold of the
%                                           specified outer fold at the
%                                           given iteration depth (maximum
%                                           iteration depth is given by the
%                                           maxIterCount field of
%                                           inputStruct).
%                                           

function [ SVMSettings, mdlStruct, errorStruct ] = SVMFunc( inputStruct )

    surveyPreds = {'patient','condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};
    posResponses = {'sp','le','ld','ld2','lcl','ap','qol','im','st'};

    % handle present and missing field values
    if isfield(inputStruct,'libLocation')
        addpath(genpath(inputStruct.libLocation));
    end
    if isfield(inputStruct,'libToUse')
        libToUse = inputStruct.libToUse;
    else
        libToUse = 1;
    end
    if isfield(inputStruct,'dirsToPath')
        temp = inputStruct.dirsToPath;
        for k = 1 : size(temp,2)
            addpath(genpath(temp{k})); 
        end
    end
    if isfield(inputStruct,'saveLocation')
        saveResults = true;
        saveLocation = inputStruct.saveLocation;
    else
        saveResults = false; 
    end
    if isfield(inputStruct,'dataLocation')
        load(inputStruct.dataLocation);
        temp = dataTable(:,end);
        temp = temp.Properties.VariableNames;
        if ~ismember(temp{1},posResponses)
            error('The last column of the table that you pass to SVMFunc must be either sp, le, ld, ld2, lcl, ap, qol, im, or st'); 
        end
    else
        error('You must provided the location of the data you wish to use'); 
    end
    if isfield(inputStruct,'response')
        response = inputStruct.response; 
    else
        error('You must provide the response you wish to predict');
    end
    myCluster = parcluster('local');
    if isfield(inputStruct,'numCores')
        numCores = inputStruct.numCores;
        myCluster.NumWorkers = numCores;
        parpool(myCluster,numCores); 
    else
        myCluster.NumWorkers = 1;
        parpool(myCluster,1);
    end
    if isfield(inputStruct,'makePlot')
        makePlot = inputStruct.makePlot;
    else
        makePlot = true; 
    end
    if isfield(inputStruct,'groupVars')
        groupVars = inputStruct.groupVars;
    else
        error('You must provide the predictors used to stratify the folds') 
    end
    if isfield(inputStruct,'seed')
        seed = inputStruct.seed;
    else
        seed = 100; 
    end
    if isfield(inputStruct,'maxIterCount')
        maxIterCount = inputStruct.maxIterCount; 
    else
        maxIterCount = 10;
    end
    if isfield(inputStruct,'crossValFolds')
        crossValFolds = inputStruct.crossValFolds; 
    else
        crossValFolds = 5;
    end
    if isfield(inputStruct,'startGammaValues')
        if libToUse == 2
            startGammaValues = [1]; 
        else
            startGammaValues = inputStruct.startGammaValues;
        end
    else
        if libToUse == 2
            startGammaValues = [1];
        else
            startGammaValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000];
        end
    end
    if isfield(inputStruct,'startCostValues')
        startCostValues = inputStruct.startCostValues; 
    else
        startCostValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000];
    end
    if isfield(inputStruct,'allowGridSearchEdgeVals')
        allowGridSearchEdgeVals = inputStruct.allowGridSearchEdgeVals;
    else
        allowGridSearchEdgeVals = false;
    end
    if isfield(inputStruct,'degree')
        degree = inputStruct.degree; 
    else
        degree = 1;
    end
    if isfield(inputStruct,'kernel')
        kernel = inputStruct.kernel;
    else
        if libToUse == 1
            kernel = 2;
        elseif libToUse == 2
            kernel = 11;
        end
    end
    if isfield(inputStruct,'toRemove')
        dataTable(:,inputStruct.toRemove) = [];
    end
    
    % get information used to find optimal place for parallelization
    innerParFor = ((ceil(size(startGammaValues,2) / numCores) * size(startCostValues,2)) + (ceil(5 / numCores) * 5 * (maxIterCount - 1))) * (crossValFolds * crossValFolds);
    outerParFor = ((size(startGammaValues,2) * size(startCostValues,2)) + (5 * 5 * (maxIterCount - 1))) * (ceil(crossValFolds / numCores) * crossValFolds);
    
    disp(strcat('Optimal SVM grid params will now be found for:',{' '},response));
    disp(strcat('Max grid search iterations:',{' '},num2str(maxIterCount)));
    disp(strcat('Outer/Inner cross validation folds:',{' '},num2str(crossValFolds)));
    disp(strcat('Degree:',{' '},num2str(degree)));
    disp(strcat('Kernal:',{' '},num2str(kernel)));
    if outerParFor <= innerParFor
        disp({'Using outer parallelization'}); 
    else
        disp({'Using inner parallelization'});
    end
    
    disp('Beginning Preprocessing');
    
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
    outerCV = cvpartition(dataTable.cvVar,'kfold',crossValFolds);
    dataTable.cvVar = [];
    
    disp('Finding and Removing Bad predictors');
    
    targetData = table2array(dataTable);
    tableNames = dataTable.Properties.VariableNames;
    index = 1;
    for outerFolds = 1 : crossValFolds
        trainingSet = targetData(training(outerCV,outerFolds),:);

        temp = dataTable(training(outerCV,outerFolds),:);
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
        innerCV = cvpartition(temp.cvVar,'kfold',crossValFolds);
        temp.cvVar = [];
        
        for innerFolds = 1 : crossValFolds
            innerTraining = trainingSet(training(innerCV,innerFolds),:);
            
            for k = 1 : size(targetData,2) - 1
                if ~ismember(tableNames{k},surveyPreds)
                    minimum = nanmin(innerTraining(:,k));
                    maximum = nanmax(innerTraining(:,k));
                    if minimum == maximum
                        toRemove(index) = k;
                        index = index + 1;
                    end
                end
            end
        end
    end
    if exist('toRemove','var')
        toRemove = unique(toRemove);
        badPredTable = dataTable(:,toRemove);
        dataTable(:,toRemove) = [];
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
    outerCV = cvpartition(dataTable.cvVar,'kfold',crossValFolds);
    dataTable.cvVar = [];
    
    tableNames = dataTable.Properties.VariableNames;
    % dummy encode survey preds
    zeroPreds = {'tf','tl','vc','cp','rs','nl','condition'};
    index = 1;
    for k = 1 : size(surveyPreds,2)
        if ismember(surveyPreds{index},tableNames)
            if index == 1
                if ismember(surveyPreds{index},zeroPreds)
                    dummyVars = dummyvar(dataTable.(surveyPreds{index}) + 1);
                    dummyVars = dummyVars(:,2:end);
                else
                    dummyVars = dummyvar(dataTable.(surveyPreds{index}));
                end
            else
                if ismember(surveyPreds{index},zeroPreds)
                    temp = dummyvar(dataTable.(surveyPreds{index}) + 1);
                    dummyVars = [dummyVars,temp(:,2:end)];
                else
                    dummyVars = [dummyVars,dummyvar(dataTable.(surveyPreds{index}))];
                end
            end
            index = index + 1;
        else
            surveyPreds(index) = [];
        end
    end
    dummyVars(:,sum(dummyVars,1) == 0) = [];
    dataTableTemp = dataTable;
    dataTableTemp(:,surveyPreds) = [];
    targetData = [dummyVars, table2array(dataTableTemp)];
    
    disp('Finding Opt Params for outer folds');
    
    gamma = zeros(1,crossValFolds);
    cost = zeros(1,crossValFolds);
    
    mdlStruct = struct;
    errorStruct = struct;
    
    if outerParFor <= innerParFor
        parfor outerFolds = 1 : crossValFolds
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Started'));
            trainingSet = targetData(training(outerCV,outerFolds),:);
            testingSet = targetData(test(outerCV,outerFolds),:);

            gammaValues = startGammaValues;
            costValues = startCostValues;

            temp = dataTable(training(outerCV,outerFolds),:);
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
            innerCV = cvpartition(temp.cvVar,'kfold',crossValFolds);
            temp.cvVar = [];

            % find opt params for current outer fold using cross validation
            optParam = true;
            preOptC = NaN;
            preOptG = NaN;
            iterationCount = 0;
            while optParam && iterationCount < maxIterCount
                iterationCount = iterationCount + 1;
                results = zeros(size(gammaValues,2),size(costValues,2),crossValFolds);
                for innerFolds = 1 : crossValFolds
                    innerTraining = trainingSet(training(innerCV,innerFolds),:);
                    innerTesting = trainingSet(test(innerCV,innerFolds),:);

                    % scale inner training and testing sets using inner training
                    % min and max
                    for k = size(dummyVars,2) + 1 : size(targetData,2) - 1
                        minimum = nanmin(innerTraining(:,k));
                        maximum = nanmax(innerTraining(:,k));
                        innerTraining(:,k) = (innerTraining(:,k) - minimum) / (maximum - minimum);
                        innerTesting(:,k) = (innerTesting(:,k) - minimum) / (maximum - minimum);
                    end

                    %Grid Search
                    [p,q] = meshgrid(gammaValues, costValues);
                    pairs = [p(:) q(:)];
                    tempResults = zeros(size(pairs,1),1);
                    outerTempStruct = struct;
                    for p = 1 : size(pairs,1)
                        if libToUse == 1
                            settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(pairs(p,1),'%f'),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mdl = svmtrain(innerTraining(:,end),innerTraining(:,1:end-1),settings{1});
                            preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
                        else
                            settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mySparseTrain = sparse(innerTraining(:,1:end-1));
                            mdl = train(innerTraining(:,end),mySparseTrain,settings{1});
                            mySparseTest = sparse(innerTesting(:,1:end-1));
                            preds = predict(innerTesting(:,end),mySparseTest,mdl);
                        end
                        
                        preds(preds < 0) = 0;
                        preds(preds > 100) = 100;
                        errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Pred',num2str(p));
                        errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Real',num2str(p));
                        innerTempStruct = struct;
                        innerTempStruct.(errorResultsNamePred) = preds;
                        innerTempStruct.(errorResultsNameReal) = innerTesting(:,end);
                        outerTempStruct = catstruct(outerTempStruct,innerTempStruct);
                        tempResults(p) = sum(abs(preds - innerTesting(:,end)));
                    end
                    for g = 1 : size(gammaValues,2)
                        results(g,1:size(costValues,2),innerFolds) = tempResults(1 + ((g - 1) * size(costValues,2)):g * size(costValues,2));
                        for c = 1 : size(costValues,2)
                            errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Pred',num2str(((g - 1) * size(costValues,2)) + c));
                            errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Real',num2str(((g - 1) * size(costValues,2)) + c));
                            tempPred = outerTempStruct.(errorResultsNamePred);
                            outerTempStruct = rmfield(outerTempStruct,errorResultsNamePred);
                            errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c),'Pred');
                            outerTempStruct.(errorResultsNamePred) = tempPred;
                            tempReal = outerTempStruct.(errorResultsNameReal);
                            outerTempStruct = rmfield(outerTempStruct,errorResultsNameReal);
                            errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c),'Real');
                            outerTempStruct.(errorResultsNameReal) = tempReal;
                        end
                    end
                    errorStruct = catstruct(errorStruct, outerTempStruct);
                end
                results = mean(results,3);
                [temp,index] = min(results(:));
                [optG,optC] = ind2sub(size(results),index);
                if ((optC == 1 || optC == size(costValues,2)) && size(costValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optC = costValues(optC);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optC = preOptC;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optC = costValues(optC);
                        optParam = false;
                    else
                        preOptC = costValues(optC);
                        if size(costValues,2) == 1
                            costValues = costValues;
                        elseif size(costValues,2) == 2
                            costValues = [costValues(1), costValues(1) + (costValues(2) - costValues(1)) / 2, costValues(2)];
                            costValues = [costValues(1), costValues(1) + ((costValues(2) - costValues(1)) / 2), costValues(2), costValues(2) + ((costValues(3) - costValues(2)) / 2), costValues(3)];
                        else
                            costValues = [costValues(optC - 1), costValues(optC - 1) + ((costValues(optC) - costValues(optC - 1)) / 2), costValues(optC), costValues(optC) + ((costValues(optC + 1) - costValues(optC)) / 2), costValues(optC + 1)];
                        end
                        optC = costValues(optC);
                    end
                end
                
                if  ((optG == 1  || optG == size(gammaValues,2)) && size(gammaValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optG = preOptG;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        preOptG = gammaValues(optG);
                        if size(gammaValues,2) == 1
                            gammaValues = gammaValues;
                        elseif size(gammaValues,2) == 2
                            gammaValues = [gammaValues(1), gammaValues(1) + (gammaValues(2) - gammaValues(1)) / 2, gammaValues(2)];
                            gammaValues = [gammaValues(1), gammaValues(1) + ((gammaValues(2) - gammaValues(1)) / 2), gammaValues(2), gammaValues(2) + ((gammaValues(3) - gammaValues(2)) / 2), gammaValues(3)];
                        else
                            gammaValues = [gammaValues(optG - 1), gammaValues(optG - 1) + ((gammaValues(optG) - gammaValues(optG - 1)) / 2), gammaValues(optG), gammaValues(optG) + ((gammaValues(optG + 1) - gammaValues(optG)) / 2), gammaValues(optG + 1)];
                        end
                        optG = gammaValues(optG);
                    end
                end
            end

            % scale outer training and testing sets for current fold
            minimum = NaN(1,size(targetData,2));
            maximum = NaN(1,size(targetData,2));
            for k = size(dummyVars,2) + 1 : size(targetData,2) - 1
                minimum(k) = nanmin(trainingSet(:,k));
                maximum(k) = nanmax(trainingSet(:,k));
                trainingSet(:,k) = (trainingSet(:,k) - minimum(k)) / (maximum(k) - minimum(k));
                testingSet(:,k) = (testingSet(:,k) - minimum(k)) / (maximum(k) - minimum(k));
            end

            gamma(outerFolds) = optG;
            cost(outerFolds) = optC;
            if libToUse == 1
                settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(optG,'%f'),{' -c'},{' '},num2str(optC,'%f')); 
                mdl = svmtrain(trainingSet(:,end),trainingSet(:,1:end-1),settings{1});
                preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
            else
                settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(optC,'%f'));
                mySparseTrain = sparse(trainingSet(:,1:end-1));
                mdl = train(trainingSet(:,end),mySparseTrain,settings{1});
                mySparseTest = sparse(testingSet(:,1:end-1));
                preds = predict(testingSet(:,end),mySparseTest,mdl);
            end
            preds(preds < 0) = 0;
            preds(preds > 100) = 100;
            mdlName = strcat('mdl',num2str(outerFolds));
            minName = strcat('minimums',num2str(outerFolds));
            maxName = strcat('maximums',num2str(outerFolds));
            temp = struct;
            temp.(mdlName) = mdl;
            temp.(minName) = minimum;
            temp.(maxName) = maximum;
            mdlStruct = catstruct(mdlStruct,temp);
            predName = strcat('outerPred',num2str(outerFolds));
            realName = strcat('outerReal',num2str(outerFolds));
            temp = struct;
            temp.(predName) = preds;
            temp.(realName) = testingSet(:,end);
            errorStruct = catstruct(errorStruct,temp);
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Completed'));
        end
    else
        for outerFolds = 1 : crossValFolds
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Started'));
            trainingSet = targetData(training(outerCV,outerFolds),:);
            testingSet = targetData(test(outerCV,outerFolds),:);

            gammaValues = startGammaValues;
            costValues = startCostValues;

            temp = dataTable(training(outerCV,outerFolds),:);
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
            innerCV = cvpartition(temp.cvVar,'kfold',crossValFolds);
            temp.cvVar = [];

            % find opt params for current outer fold using cross validation
            optParam = true;
            preOptC = NaN;
            preOptG = NaN;
            iterationCount = 0;
            while optParam && iterationCount < maxIterCount
                iterationCount = iterationCount + 1;
                results = zeros(size(gammaValues,2),size(costValues,2),crossValFolds);
                for innerFolds = 1 : crossValFolds
                    innerTraining = trainingSet(training(innerCV,innerFolds),:);
                    innerTesting = trainingSet(test(innerCV,innerFolds),:);

                    % scale inner training and testing sets using inner training
                    % min and max
                    for k = size(dummyVars,2) + 1 : size(targetData,2) - 1
                        minimum = nanmin(innerTraining(:,k));
                        maximum = nanmax(innerTraining(:,k));
                        innerTraining(:,k) = (innerTraining(:,k) - minimum) / (maximum - minimum);
                        innerTesting(:,k) = (innerTesting(:,k) - minimum) / (maximum - minimum);
                    end

                    %Grid Search
                    [p,q] = meshgrid(gammaValues, costValues);
                    pairs = [p(:) q(:)];
                    tempResults = zeros(size(pairs,1),1);
                    outerTempStruct = struct;
                    parfor p = 1 : size(pairs,1)
                        if libToUse == 1
                            settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(pairs(p,1),'%f'),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mdl = svmtrain(innerTraining(:,end),innerTraining(:,1:end-1),settings{1});
                            preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
                        else
                            settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mySparseTrain = sparse(innerTraining(:,1:end-1));
                            mdl = train(innerTraining(:,end),mySparseTrain,settings{1});
                            mySparseTest = sparse(innerTesting(:,1:end-1));
                            preds = predict(innerTesting(:,end),mySparseTest,mdl);
                        end
                        
                        preds(preds < 0) = 0;
                        preds(preds > 100) = 100;
                        errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Pred',num2str(p));
                        errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Real',num2str(p));
                        innerTempStruct = struct;
                        innerTempStruct.(errorResultsNamePred) = preds;
                        innerTempStruct.(errorResultsNameReal) = innerTesting(:,end);
                        outerTempStruct = catstruct(outerTempStruct,innerTempStruct);
                        tempResults(p) = sum(abs(preds - innerTesting(:,end)));
                    end
                    for g = 1 : size(gammaValues,2)
                        results(g,1:size(costValues,2),innerFolds) = tempResults(1 + ((g - 1) * size(costValues,2)):g * size(costValues,2));
                        for c = 1 : size(costValues,2)
                            errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Pred',num2str(((g - 1) * size(costValues,2)) + c));
                            errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Real',num2str(((g - 1) * size(costValues,2)) + c));
                            tempPred = outerTempStruct.(errorResultsNamePred);
                            outerTempStruct = rmfield(outerTempStruct,errorResultsNamePred);
                            errorResultsNamePred = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c),'Pred');
                            outerTempStruct.(errorResultsNamePred) = tempPred;
                            tempReal = outerTempStruct.(errorResultsNameReal);
                            outerTempStruct = rmfield(outerTempStruct,errorResultsNameReal);
                            errorResultsNameReal = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c),'Real');
                            outerTempStruct.(errorResultsNameReal) = tempReal;
                        end
                    end
                    errorStruct = catstruct(errorStruct, outerTempStruct);
                end
                results = mean(results,3);
                [temp,index] = min(results(:));
                [optG,optC] = ind2sub(size(results),index);
                if ((optC == 1 || optC == size(costValues,2)) && size(costValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optC = costValues(optC);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optC = preOptC;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optC = costValues(optC);
                        optParam = false;
                    else
                        preOptC = costValues(optC);
                        if size(costValues,2) == 1
                            costValues = costValues;
                        elseif size(costValues,2) == 2
                            costValues = [costValues(1), costValues(1) + (costValues(2) - costValues(1)) / 2, costValues(2)];
                            costValues = [costValues(1), costValues(1) + ((costValues(2) - costValues(1)) / 2), costValues(2), costValues(2) + ((costValues(3) - costValues(2)) / 2), costValues(3)];
                        else
                            costValues = [costValues(optC - 1), costValues(optC - 1) + ((costValues(optC) - costValues(optC - 1)) / 2), costValues(optC), costValues(optC) + ((costValues(optC + 1) - costValues(optC)) / 2), costValues(optC + 1)];
                        end
                        optC = costValues(optC);
                    end
                end
                
                if  ((optG == 1  || optG == size(gammaValues,2)) && size(gammaValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optG = preOptG;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        preOptG = gammaValues(optG);
                        if size(gammaValues,2) == 1
                            gammaValues = gammaValues;
                        elseif size(gammaValues,2) == 2
                            gammaValues = [gammaValues(1), gammaValues(1) + (gammaValues(2) - gammaValues(1)) / 2, gammaValues(2)];
                            gammaValues = [gammaValues(1), gammaValues(1) + ((gammaValues(2) - gammaValues(1)) / 2), gammaValues(2), gammaValues(2) + ((gammaValues(3) - gammaValues(2)) / 2), gammaValues(3)];
                        else
                            gammaValues = [gammaValues(optG - 1), gammaValues(optG - 1) + ((gammaValues(optG) - gammaValues(optG - 1)) / 2), gammaValues(optG), gammaValues(optG) + ((gammaValues(optG + 1) - gammaValues(optG)) / 2), gammaValues(optG + 1)];
                        end
                        optG = gammaValues(optG);
                    end
                end
            end

            % scale outer training and testing sets for current fold
            minimum = NaN(1,size(targetData,2));
            maximum = NaN(1,size(targetData,2));
            for k = size(dummyVars,2) + 1 : size(targetData,2) - 1
                minimum(k) = nanmin(trainingSet(:,k));
                maximum(k) = nanmax(trainingSet(:,k));
                trainingSet(:,k) = (trainingSet(:,k) - minimum(k)) / (maximum(k) - minimum(k));
                testingSet(:,k) = (testingSet(:,k) - minimum(k)) / (maximum(k) - minimum(k));
            end

            gamma(outerFolds) = optG;
            cost(outerFolds) = optC;
            if libToUse == 1
                settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(optG,'%f'),{' -c'},{' '},num2str(optC,'%f')); 
                mdl = svmtrain(trainingSet(:,end),trainingSet(:,1:end-1),settings{1});
                preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
            else
                settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(optC,'%f'));
                mySparseTrain = sparse(trainingSet(:,1:end-1));
                mdl = train(trainingSet(:,end),mySparseTrain,settings{1});
                mySparseTest = sparse(testingSet(:,1:end-1));
                preds = predict(testingSet(:,end),mySparseTest,mdl);
            end
            preds(preds < 0) = 0;
            preds(preds > 100) = 100;
            mdlName = strcat('mdl',num2str(outerFolds));
            minName = strcat('minimums',num2str(outerFolds));
            maxName = strcat('maximums',num2str(outerFolds));
            temp = struct;
            temp.(mdlName) = mdl;
            temp.(minName) = minimum;
            temp.(maxName) = maximum;
            mdlStruct = catstruct(mdlStruct,temp);
            predName = strcat('outerPred',num2str(outerFolds));
            realName = strcat('outerReal',num2str(outerFolds));
            temp = struct;
            temp.(predName) = preds;
            temp.(realName) = testingSet(:,end);
            errorStruct = catstruct(errorStruct,temp);
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Completed'));
        end
    end
    delete(gcp);
    
    if crossValFolds == 5 && makePlot
        hold on;
        h = cdfplot(abs(errorStruct.outerPred1 - errorStruct.outerReal1));
        set(h,'color','b');
        h = cdfplot(abs(errorStruct.outerPred2 - errorStruct.outerReal2));
        set(h,'color','r');
        h = cdfplot(abs(errorStruct.outerPred3 - errorStruct.outerReal3));
        set(h,'color','g');
        h = cdfplot(abs(errorStruct.outerPred4 - errorStruct.outerReal4));
        set(h,'color','c');
        h = cdfplot(abs(errorStruct.outerPred5 - errorStruct.outerReal5));
        set(h,'color','k');
        title(strcat('Cross Validation Results for',{' '},response{1}));
        xlabel('Abs Error');
        ylabel('Cumulative Percent');
        axis([0 100 0 1]);
        legend('Fold 1','Fold 2','Fold 3','Fold 4','Fold 5');
        hold off;
        if saveResults
            savefig(strcat(saveLocation,'.fig'));
        end
    end
    
    SVMSettings = struct;
    SVMSettings.cost = cost;
    SVMSettings.gamma = gamma;
    SVMSettings.seed = seed;
    SVMSettings.dataTable = dataTable;
    SVMSettings.targetData = targetData;
    SVMSettings.degree = degree;
    SVMSettings.kernal = kernel;
    SVMSettings.groupVars = groupVars;
    SVMSettings.startGammaValues = startGammaValues;
    SVMSettings.startCostValues = startCostValues;
    SVMSettings.crossValFolds = crossValFolds;
    
    if exist('badPredTable','var')
        SVMSettings.badPredNames = badPredTable.Properties.VariableNames;
    else
        SVMSettings.badPredNames = NaN;
    end
    
    if saveResults
        save(saveLocation,'SVMSettings','mdlStruct','errorStruct','-v7.3'); 
    end
    
end

